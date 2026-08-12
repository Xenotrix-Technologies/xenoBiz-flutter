const { v4: uuidv4 } = require('uuid');
const crmRepository = require('../repositories/crm_repository');

class CrmService {
  async getPipeline(businessId) {
    let pipeline = crmRepository.findPipelineByBusinessId(businessId);
    if (!pipeline) {
      // Create default pipeline with standard stages
      const pipeId = `pipe_${uuidv4().substring(0, 8)}`;
      pipeline = crmRepository.createPipeline({
        id: pipeId,
        businessId,
        name: 'Sales Pipeline',
        isDefault: 1,
      });

      const defaultStages = [
        { name: 'New Lead', order: 1, color: '#3B82F6' },
        { name: 'Contacted', order: 2, color: '#8B5CF6' },
        { name: 'Qualified', order: 3, color: '#EC4899' },
        { name: 'Proposal', order: 4, color: '#F59E0B' },
        { name: 'Negotiation', order: 5, color: '#10B981' },
        { name: 'Won', order: 6, color: '#059669' },
        { name: 'Lost', order: 7, color: '#EF4444' },
      ];

      for (const st of defaultStages) {
        crmRepository.createStage({
          id: `stg_${uuidv4().substring(0, 8)}`,
          pipelineId: pipeId,
          name: st.name,
          stageOrder: st.order,
          color: st.color,
        });
      }
    }

    const stages = crmRepository.getStages(pipeline.id);
    return { ...pipeline, stages };
  }

  async getLeads(businessId, options) {
    return crmRepository.findAllLeads(businessId, options);
  }

  async getLeadById(id, businessId) {
    const lead = crmRepository.findLeadById(id, businessId);
    if (!lead) {
      throw { statusCode: 404, message: 'CRM Lead not found.' };
    }
    return lead;
  }

  async createLead(businessId, leadData, userId) {
    if (!leadData.title) {
      throw { statusCode: 400, message: 'Lead title is required.' };
    }

    const pipeline = await this.getPipeline(businessId);
    const defaultStage = pipeline.stages[0];

    const lead = {
      id: `lead_${uuidv4().substring(0, 8)}`,
      businessId,
      pipelineId: leadData.pipelineId || pipeline.id,
      stageId: leadData.stageId || (defaultStage ? defaultStage.id : null),
      customerId: leadData.customerId || null,
      title: leadData.title,
      contactName: leadData.contactName || null,
      contactPhone: leadData.contactPhone || null,
      contactEmail: leadData.contactEmail || null,
      leadValue: leadData.leadValue || 0.0,
      status: leadData.status || 'open',
      priority: leadData.priority || 'medium',
      assignedUserId: leadData.assignedUserId || userId,
      expectedClosingDate: leadData.expectedClosingDate || null,
      notes: leadData.notes || null,
      createdBy: userId,
    };

    return crmRepository.createLead(lead);
  }

  async updateLead(id, businessId, updates) {
    const existing = crmRepository.findLeadById(id, businessId);
    if (!existing) {
      throw { statusCode: 404, message: 'CRM Lead not found.' };
    }
    return crmRepository.updateLead(id, businessId, updates);
  }

  async deleteLead(id, businessId) {
    return crmRepository.deleteLead(id, businessId);
  }
}

module.exports = new CrmService();
