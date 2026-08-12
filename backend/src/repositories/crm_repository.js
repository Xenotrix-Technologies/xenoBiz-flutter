const { db } = require('../db/database');

class CrmRepository {
  // Pipelines
  findPipelineByBusinessId(businessId) {
    return db.prepare('SELECT * FROM crm_pipelines WHERE business_id = ? ORDER BY is_default DESC, created_at ASC').get(businessId);
  }

  createPipeline(pipeline) {
    db.prepare(`
      INSERT INTO crm_pipelines (id, business_id, name, is_default, created_at)
      VALUES (?, ?, ?, ?, ?)
    `).run(
      pipeline.id,
      pipeline.businessId || pipeline.business_id,
      pipeline.name,
      pipeline.isDefault !== undefined ? (pipeline.isDefault ? 1 : 0) : 1,
      pipeline.createdAt || new Date().toISOString()
    );
    return db.prepare('SELECT * FROM crm_pipelines WHERE id = ?').get(pipeline.id);
  }

  // Stages
  getStages(pipelineId) {
    return db.prepare('SELECT * FROM crm_stages WHERE pipeline_id = ? ORDER BY stage_order ASC').all(pipelineId);
  }

  createStage(stage) {
    db.prepare(`
      INSERT INTO crm_stages (id, pipeline_id, name, stage_order, color, created_at)
      VALUES (?, ?, ?, ?, ?, ?)
    `).run(
      stage.id,
      stage.pipelineId || stage.pipeline_id,
      stage.name,
      stage.stageOrder || stage.stage_order || 1,
      stage.color || '#2563EB',
      stage.createdAt || new Date().toISOString()
    );
    return db.prepare('SELECT * FROM crm_stages WHERE id = ?').get(stage.id);
  }

  // Leads
  findLeadById(id, businessId) {
    return db.prepare(`
      SELECT l.*, c.name as customer_name, s.name as stage_name
      FROM crm_leads l
      LEFT JOIN customers c ON l.customer_id = c.id
      LEFT JOIN crm_stages s ON l.stage_id = s.id
      WHERE l.id = ? AND l.business_id = ?
    `).get(id, businessId);
  }

  findAllLeads(businessId, { stageId, status, search, limit = 100, offset = 0 } = {}) {
    let sql = `
      SELECT l.*, c.name as customer_name, s.name as stage_name
      FROM crm_leads l
      LEFT JOIN customers c ON l.customer_id = c.id
      LEFT JOIN crm_stages s ON l.stage_id = s.id
      WHERE l.business_id = ?
    `;
    const params = [businessId];

    if (stageId) {
      sql += ' AND l.stage_id = ?';
      params.push(stageId);
    }
    if (status) {
      sql += ' AND l.status = ?';
      params.push(status);
    }
    if (search) {
      sql += ' AND (LOWER(l.title) LIKE LOWER(?) OR LOWER(l.contact_name) LIKE LOWER(?) OR LOWER(l.contact_email) LIKE LOWER(?))';
      const term = `%${search}%`;
      params.push(term, term, term);
    }

    sql += ' ORDER BY l.created_at DESC LIMIT ? OFFSET ?';
    params.push(limit, offset);

    return db.prepare(sql).all(...params);
  }

  createLead(lead) {
    const now = new Date().toISOString();
    db.prepare(`
      INSERT INTO crm_leads (
        id, business_id, pipeline_id, stage_id, customer_id, title, contact_name,
        contact_phone, contact_email, lead_value, status, priority, assigned_user_id,
        expected_closing_date, notes, created_at, updated_at, created_by
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `).run(
      lead.id,
      lead.businessId || lead.business_id,
      lead.pipelineId || lead.pipeline_id || null,
      lead.stageId || lead.stage_id || null,
      lead.customerId || lead.customer_id || null,
      lead.title,
      lead.contactName || lead.contact_name || null,
      lead.contactPhone || lead.contact_phone || null,
      lead.contactEmail || lead.contact_email || null,
      lead.leadValue || lead.lead_value || 0.0,
      lead.status || 'open',
      lead.priority || 'medium',
      lead.assignedUserId || lead.assigned_user_id || null,
      lead.expectedClosingDate || lead.expected_closing_date || null,
      lead.notes || null,
      lead.createdAt || now,
      lead.updatedAt || now,
      lead.createdBy || lead.created_by || null
    );

    return this.findLeadById(lead.id, lead.businessId || lead.business_id);
  }

  updateLead(id, businessId, updates) {
    const fields = [];
    const values = [];
    const now = new Date().toISOString();

    const map = {
      stageId: 'stage_id = ?',
      stage_id: 'stage_id = ?',
      pipelineId: 'pipeline_id = ?',
      pipeline_id: 'pipeline_id = ?',
      customerId: 'customer_id = ?',
      customer_id: 'customer_id = ?',
      title: 'title = ?',
      contactName: 'contact_name = ?',
      contact_name: 'contact_name = ?',
      contactPhone: 'contact_phone = ?',
      contact_phone: 'contact_phone = ?',
      contactEmail: 'contact_email = ?',
      contact_email: 'contact_email = ?',
      leadValue: 'lead_value = ?',
      lead_value: 'lead_value = ?',
      status: 'status = ?',
      priority: 'priority = ?',
      assignedUserId: 'assigned_user_id = ?',
      assigned_user_id: 'assigned_user_id = ?',
      expectedClosingDate: 'expected_closing_date = ?',
      expected_closing_date: 'expected_closing_date = ?',
      notes: 'notes = ?'
    };

    Object.keys(updates).forEach((k) => {
      if (map[k]) {
        fields.push(map[k]);
        values.push(updates[k]);
      }
    });

    fields.push('updated_at = ?');
    values.push(now);
    values.push(id, businessId);

    db.prepare(`UPDATE crm_leads SET ${fields.join(', ')} WHERE id = ? AND business_id = ?`).run(...values);
    return this.findLeadById(id, businessId);
  }

  deleteLead(id, businessId) {
    return db.prepare('DELETE FROM crm_leads WHERE id = ? AND business_id = ?').run(id, businessId);
  }
}

module.exports = new CrmRepository();
