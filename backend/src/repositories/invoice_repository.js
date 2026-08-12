const { db } = require('../db/database');

class InvoiceRepository {
  findById(id, businessId) {
    const invoice = db.prepare(`
      SELECT i.*, c.email as customer_email, c.phone as customer_phone, c.address as customer_address
      FROM invoices i
      LEFT JOIN customers c ON i.customer_id = c.id
      WHERE i.id = ? AND i.business_id = ?
    `).get(id, businessId);

    if (!invoice) return null;

    const items = db.prepare('SELECT * FROM invoice_items WHERE invoice_id = ?').all(id);
    invoice.items = items;
    return invoice;
  }

  findByInvoiceNumber(invoiceNumber, businessId) {
    return db.prepare('SELECT * FROM invoices WHERE invoice_number = ? AND business_id = ?').get(invoiceNumber, businessId);
  }

  findAll(businessId, { customerId, paymentStatus, startDate, endDate, status, search, limit = 100, offset = 0 } = {}) {
    let sql = `
      SELECT i.*, c.email as customer_email, c.phone as customer_phone
      FROM invoices i
      LEFT JOIN customers c ON i.customer_id = c.id
      WHERE i.business_id = ?
    `;
    const params = [businessId];

    if (customerId) {
      sql += ' AND i.customer_id = ?';
      params.push(customerId);
    }
    if (paymentStatus) {
      sql += ' AND i.payment_status = ?';
      params.push(paymentStatus);
    }
    if (status) {
      sql += ' AND i.status = ?';
      params.push(status);
    }
    if (startDate) {
      sql += ' AND i.issue_date >= ?';
      params.push(startDate);
    }
    if (endDate) {
      sql += ' AND i.issue_date <= ?';
      params.push(endDate);
    }
    if (search) {
      sql += ' AND (LOWER(i.invoice_number) LIKE LOWER(?) OR LOWER(i.customer_name) LIKE LOWER(?))';
      const term = `%${search}%`;
      params.push(term, term);
    }

    sql += ' ORDER BY i.issue_date DESC LIMIT ? OFFSET ?';
    params.push(limit, offset);

    return db.prepare(sql).all(...params);
  }

  count(businessId) {
    const res = db.prepare('SELECT COUNT(*) as count FROM invoices WHERE business_id = ?').get(businessId);
    return res ? res.count : 0;
  }

  countOverdue(businessId) {
    const now = new Date().toISOString();
    const res = db.prepare("SELECT COUNT(*) as count FROM invoices WHERE business_id = ? AND payment_status != 'paid' AND due_date < ?").get(businessId, now);
    return res ? res.count : 0;
  }

  create(invoice, items = []) {
    const now = new Date().toISOString();
    const insertInv = db.prepare(`
      INSERT INTO invoices (
        id, business_id, invoice_number, customer_id, customer_name, issue_date, due_date,
        subtotal, discount, tax_amount, other_charges, grand_total, paid_amount, due_amount,
        payment_status, payment_method, status, notes, created_at, updated_at, created_by
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `);

    const insertItem = db.prepare(`
      INSERT INTO invoice_items (id, invoice_id, product_id, product_name, quantity, unit_price, discount, tax, total)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    `);

    const tx = db.transaction(() => {
      insertInv.run(
        invoice.id,
        invoice.businessId || invoice.business_id,
        invoice.invoiceNumber || invoice.invoice_number,
        invoice.customerId || invoice.customer_id || null,
        invoice.customerName || invoice.customer_name || null,
        invoice.issueDate || invoice.issue_date || now,
        invoice.dueDate || invoice.due_date || null,
        invoice.subtotal || 0.0,
        invoice.discount || 0.0,
        invoice.taxAmount || invoice.tax_amount || 0.0,
        invoice.otherCharges || invoice.other_charges || 0.0,
        invoice.grandTotal || invoice.grand_total || 0.0,
        invoice.paidAmount || invoice.paid_amount || 0.0,
        invoice.dueAmount || invoice.due_amount || 0.0,
        invoice.paymentStatus || invoice.payment_status || 'unpaid',
        invoice.paymentMethod || invoice.payment_method || 'Cash',
        invoice.status || 'active',
        invoice.notes || null,
        invoice.createdAt || now,
        invoice.updatedAt || now,
        invoice.createdBy || invoice.created_by || null
      );

      for (const item of items) {
        insertItem.run(
          item.id,
          invoice.id,
          item.productId || item.product_id || null,
          item.productName || item.product_name,
          item.quantity,
          item.unitPrice || item.unit_price,
          item.discount || 0.0,
          item.tax || 0.0,
          item.total
        );
      }
    });

    tx();
    return this.findById(invoice.id, invoice.businessId || invoice.business_id);
  }

  updatePayment(id, businessId, addPaidAmount) {
    const inv = this.findById(id, businessId);
    if (!inv) return null;

    const newPaid = inv.paid_amount + addPaidAmount;
    const newDue = Math.max(0, inv.grand_total - newPaid);
    let newStatus = 'unpaid';
    if (newDue <= 0) {
      newStatus = 'paid';
    } else if (newPaid > 0) {
      newStatus = 'partially_paid';
    }

    db.prepare(`
      UPDATE invoices
      SET paid_amount = ?, due_amount = ?, payment_status = ?, updated_at = ?
      WHERE id = ? AND business_id = ?
    `).run(newPaid, newDue, newStatus, new Date().toISOString(), id, businessId);

    return this.findById(id, businessId);
  }

  cancel(id, businessId) {
    db.prepare('UPDATE invoices SET status = "cancelled", updated_at = ? WHERE id = ? AND business_id = ?').run(new Date().toISOString(), id, businessId);
    return this.findById(id, businessId);
  }
}

module.exports = new InvoiceRepository();
