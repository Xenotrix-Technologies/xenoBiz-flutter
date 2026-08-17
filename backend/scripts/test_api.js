const http = require('http');

console.log('🧪 Running XenoBiz Shop & Subscription Backend API Sanity Tests...');

function makeRequest(path, method = 'GET', body = null, token = null) {
  return new Promise((resolve, reject) => {
    const headers = { 'Content-Type': 'application/json' };
    if (token) headers['Authorization'] = `Bearer ${token}`;

    const options = {
      hostname: '127.0.0.1',
      port: process.env.PORT || 3000,
      path: `/api/v1${path}`,
      method,
      headers,
    };

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => (data += chunk));
      res.on('end', () => {
        try {
          const parsed = JSON.parse(data);
          resolve({ status: res.statusCode, body: parsed });
        } catch (_) {
          resolve({ status: res.statusCode, body: data });
        }
      });
    });

    req.on('error', (err) => reject(err));

    if (body) {
      req.write(JSON.stringify(body));
    }
    req.end();
  });
}

async function runTests() {
  try {
    // 1. Health check
    const health = await makeRequest('/health');
    console.log('1. Health Check:', health.status === 200 ? '✅ PASSED' : '❌ FAILED', health.body);

    // 2. Login as NovaTech Owner
    const loginRes = await makeRequest('/auth/login', 'POST', {
      identifier: 'demo@xenobiz.local',
      password: 'Demo@12345',
    });

    console.log('2. Shop Account Login:', loginRes.status === 200 && loginRes.body.success ? '✅ PASSED' : '❌ FAILED');
    const token = loginRes.body?.data?.token;

    if (token) {
      // 3. Get Shop Profile
      const profileRes = await makeRequest('/shops/me', 'GET', null, token);
      console.log('3. Get Shop Profile (/shops/me):', profileRes.status === 200 && profileRes.body.success ? '✅ PASSED' : '❌ FAILED');

      // 4. Get Subscription Plans
      const plansRes = await makeRequest('/plans', 'GET');
      console.log('4. Get Subscription Plans (/plans):', plansRes.status === 200 && plansRes.body.success ? '✅ PASSED' : '❌ FAILED');

      // 5. Get Current Subscription
      const subRes = await makeRequest('/subscriptions/me', 'GET', null, token);
      console.log('5. Get Current Subscription (/subscriptions/me):', subRes.status === 200 && subRes.body.success ? '✅ PASSED' : '❌ FAILED');

      // 6. Get Payment History
      const payRes = await makeRequest('/payments/my-history', 'GET', null, token);
      console.log('6. Get Billing Payment History (/payments/my-history):', payRes.status === 200 && payRes.body.success ? '✅ PASSED' : '❌ FAILED');

      // 7. Get Admin Dashboard
      const adminRes = await makeRequest('/admin/dashboard', 'GET');
      console.log('7. Get Admin Dashboard (/admin/dashboard):', adminRes.status === 200 && adminRes.body.success ? '✅ PASSED' : '❌ FAILED');
    }

    console.log('--------------------------------------------------');
    console.log('🎉 All Backend API Sanity Tests Completed!');
  } catch (err) {
    console.error('❌ Tests failed to run:', err.message);
  }
}

runTests();
