const subscriptionService = require('../services/subscription_service');

class SubscriptionController {
  async getPlans(req, res, next) {
    try {
      const plans = await subscriptionService.getPlans();
      res.json({
        success: true,
        data: plans,
      });
    } catch (err) {
      next(err);
    }
  }

  async getMySubscription(req, res, next) {
    try {
      const shopId = req.user.shopId;
      const subscription = await subscriptionService.getShopSubscription(shopId);
      res.json({
        success: true,
        data: subscription,
      });
    } catch (err) {
      next(err);
    }
  }

  async subscribe(req, res, next) {
    try {
      const shopId = req.user.shopId;
      const { planId, paymentMethod, transactionId } = req.body;

      if (!planId) {
        return res.status(400).json({ success: false, message: 'planId is required.' });
      }

      const result = await subscriptionService.subscribe(shopId, {
        planId,
        paymentMethod,
        transactionId,
      });

      res.status(201).json({
        success: true,
        message: 'Subscription updated successfully!',
        data: result,
      });
    } catch (err) {
      next(err);
    }
  }

  async cancel(req, res, next) {
    try {
      const shopId = req.user.shopId;
      const subscription = await subscriptionService.cancelSubscription(shopId);
      res.json({
        success: true,
        message: 'Subscription cancelled successfully.',
        data: subscription,
      });
    } catch (err) {
      next(err);
    }
  }
}

module.exports = new SubscriptionController();
