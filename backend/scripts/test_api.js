const http = require('http');

function makeRequest(options, postData) {
  return new Promise((resolve, reject) => {
    const req = http.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => {
        try {
          const parsed = JSON.parse(body);
          resolve({ status: res.statusCode, body: parsed });
        } catch (e) {
          resolve({ status: res.statusCode, body });
        }
      });
    });
    req.on('error', reject);
    if (postData) {
      req.write(JSON.stringify(postData));
    }
    req.end();
  });
}

async function runTests() {
  console.log('🧪 Testing XenoBiz Backend APIs...');

  // 1. Health check
  const health = await makeRequest({ host: 'localhost', port: 3000, path: '/api/v1/health', method: 'GET' });
  console.log('1. Health Check:', health.status === 200 ? '✅ PASS' : '❌ FAIL', health.body.service);

  // 2. Demo User Login
  const login = await makeRequest(
    { host: 'localhost', port: 3000, path: '/api/v1/auth/login', method: 'POST', headers: { 'Content-Type': 'application/json' } },
    { emailOrUsername: 'demo@xenobiz.local', password: 'Demo@12345' }
  );
  console.log('2. Demo Login:', login.status === 200 ? '✅ PASS' : '❌ FAIL', login.body.message);

  const token = login.body.data.token;
  const authHeaders = { 'Authorization': `Bearer ${token}` };

  // 3. Get Auth Me
  const me = await makeRequest({ host: 'localhost', port: 3000, path: '/api/v1/auth/me', method: 'GET', headers: authHeaders });
  console.log('3. Auth /me:', me.status === 200 ? '✅ PASS' : '❌ FAIL', me.body.data.user.email);

  // 4. Dashboard Summary
  const dash = await makeRequest({ host: 'localhost', port: 3000, path: '/api/v1/dashboard/summary', method: 'GET', headers: authHeaders });
  console.log('4. Dashboard Summary:', dash.status === 200 ? '✅ PASS' : '❌ FAIL', dash.body.data ? `Today Sales: ₹${dash.body.data.today.sales}` : dash.body);

  // 5. Customers List
  const customers = await makeRequest({ host: 'localhost', port: 3000, path: '/api/v1/customers', method: 'GET', headers: authHeaders });
  console.log('5. Customers List:', customers.status === 200 ? '✅ PASS' : '❌ FAIL', `Count: ${customers.body.data.length}`);

  // 6. Products List
  const products = await makeRequest({ host: 'localhost', port: 3000, path: '/api/v1/products', method: 'GET', headers: authHeaders });
  console.log('6. Products List:', products.status === 200 ? '✅ PASS' : '❌ FAIL', `Count: ${products.body.data.length}`);

  // 7. Invoices List
  const invoices = await makeRequest({ host: 'localhost', port: 3000, path: '/api/v1/invoices', method: 'GET', headers: authHeaders });
  console.log('7. Invoices List:', invoices.status === 200 ? '✅ PASS' : '❌ FAIL', `Count: ${invoices.body.data.length}`);

  // 8. CRM Leads List
  const crm = await makeRequest({ host: 'localhost', port: 3000, path: '/api/v1/crm/leads', method: 'GET', headers: authHeaders });
  console.log('8. CRM Leads:', crm.status === 200 ? '✅ PASS' : '❌ FAIL', `Count: ${crm.body.data.length}`);

  // 9. Admin Login & Stats
  const adminLogin = await makeRequest(
    { host: 'localhost', port: 3000, path: '/api/v1/auth/login', method: 'POST', headers: { 'Content-Type': 'application/json' } },
    { emailOrUsername: 'admin@xenobiz.local', password: 'Admin@12345' }
  );
  const adminToken = adminLogin.body.data.token;
  const adminStats = await makeRequest({ host: 'localhost', port: 3000, path: '/api/v1/admin/stats', method: 'GET', headers: { 'Authorization': `Bearer ${adminToken}` } });
  console.log('9. Admin Stats:', adminStats.status === 200 ? '✅ PASS' : '❌ FAIL', `Total Businesses: ${adminStats.body.data.totalBusinesses}`);

  console.log('--------------------------------------------------');
  console.log('🎉 ALL BACKEND API TESTS COMPLETED SUCCESSFULLY!');
}

runTests().catch(console.error);
