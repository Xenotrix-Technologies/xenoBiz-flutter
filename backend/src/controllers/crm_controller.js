const crmService = require('../services/crm_service');

class CrmController {
  async getPipeline(req, res, next) {
    try {
      const pipeline = await crmService.getPipeline(req.businessId);
      res.json({
        success: true,
        data: pipeline,
      });
    } catch (err) {
      next(err);
    }
  }

  async getLeads(req, res, next) {
    try {
      const { stageId, status, search, limit, offset } = req.query;
      const leads = await crmService.getLeads(req.businessId, {
        stageId,
        status,
        search,
        limit: limit ? parseInt(limit) : 100,
        offset: offset ? parseInt(offset) : 0,
      });

      res.json({
        success: true,
        data: leads,
      });
    } catch (err) {
      next(err);
    }
  }

  async getLeadById(req, res, next) {
    try {
      const lead = await crmService.getLeadById(req.params.id, req.businessId);
      res.json({
        success: true,
        data: lead,
      });
    } catch (err) {
      next(err);
    }
  }

  async createLead(req, res, next) {
    try {
      const lead = await crmService.createLead(req.businessId, req.body, req.user.userId);
      res.status(201).json({
        success: true,
        message: 'Lead created successfully!',
        data: lead,
      });
    } catch (err) {
      next(err);
    }
  }

  async updateLead(req, res, next) {
    try {
      const updated = await crmService.updateLead(req.params.id, req.businessId, req.body);
      res.json({
        success: true,
        message: 'Lead updated successfully!',
        data: updated,
      });
    } catch (err) {
      next(err);
    }
  }

  async deleteLead(req, res, next) {
    try {
      await crmService.deleteLead(req.params.id, req.businessId);
      res.json({
        success: true,
        message: 'Lead deleted successfully!',
      });
    } catch (err) {
      next(err);
    }
  }
}

module.exports = new CrmController();
