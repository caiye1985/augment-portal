// 简单的页面验收测试脚本
import { chromium } from '@playwright/test';

async function testPages() {
  console.log('🚀 开始页面验收测试...');

  const browser = await chromium.launch({ headless: false });
  const context = await browser.newContext();
  const page = await context.newPage();

  // 测试页面列表
  const testPages = [
    { name: '仪表板', path: '/' },
    { name: '租户管理', path: '/tenant-management' },
    { name: '部门管理', path: '/department-management' },
    { name: '工单管理', path: '/ticket' },
    { name: '智能派单', path: '/dispatch' },
    { name: '知识库管理', path: '/knowledge' },
    { name: '我的任务', path: '/my-tasks' },
    { name: '我的消息', path: '/my-messages' },
    { name: 'AI分析', path: '/ai-analysis' },
    { name: '客户管理', path: '/client-management' },
    { name: '工程师管理', path: '/engineer-management' },
    { name: '系统集成', path: '/integration' },
    { name: '通知管理', path: '/notification' },
    { name: '排班管理', path: '/schedule-management' },
    { name: '技能管理', path: '/skill-management' },
    { name: '用户管理', path: '/user-management' },
    { name: '站点总览', path: '/site-overview' },
    { name: '考核管理', path: '/exam-management' },
    { name: '系统配置', path: '/system-config' },
    { name: '用户手册', path: '/user-manual' },
    { name: '工程师租户分配', path: '/engineer-tenant-management' },
    { name: '工作流管理', path: '/workflow' }
  ];

  const results = [];

  for (const testPage of testPages) {
    try {
      console.log(`📄 测试页面: ${testPage.name} (${testPage.path})`);

      await page.goto(`http://localhost:3001${testPage.path}`, {
        waitUntil: 'networkidle',
        timeout: 10000
      });

      // 等待页面加载
      await page.waitForTimeout(2000);

      // 检查页面标题
      const title = await page.title();

      // 检查是否有PageLayout组件
      const hasPageLayout = await page.locator('.page-layout').count() > 0;

      // 检查是否有统计卡片
      const hasStatCards = await page.locator('.stat-card').count() > 0;

      // 检查是否有错误
      const hasErrors = await page.locator('.error, .el-message--error').count() > 0;

      // 检查控制台错误
      const consoleErrors = [];
      page.on('console', msg => {
        if (msg.type() === 'error') {
          consoleErrors.push(msg.text());
        }
      });

      results.push({
        name: testPage.name,
        path: testPage.path,
        success: true,
        title,
        hasPageLayout,
        hasStatCards,
        hasErrors,
        consoleErrors: consoleErrors.length
      });

      console.log(`✅ ${testPage.name} - 加载成功`);

    } catch (error) {
      console.log(`❌ ${testPage.name} - 加载失败: ${error.message}`);
      results.push({
        name: testPage.name,
        path: testPage.path,
        success: false,
        error: error.message
      });
    }
  }

  await browser.close();

  // 输出测试结果
  console.log('\n📊 测试结果汇总:');
  console.log('='.repeat(80));

  const successCount = results.filter(r => r.success).length;
  const failCount = results.filter(r => !r.success).length;

  console.log(`✅ 成功页面: ${successCount}/${results.length}`);
  console.log(`❌ 失败页面: ${failCount}/${results.length}`);

  if (failCount > 0) {
    console.log('\n❌ 失败页面详情:');
    results.filter(r => !r.success).forEach(result => {
      console.log(`  - ${result.name}: ${result.error}`);
    });
  }

  console.log('\n✅ 成功页面详情:');
  results.filter(r => r.success).forEach(result => {
    console.log(`  - ${result.name}: PageLayout=${result.hasPageLayout}, StatCards=${result.hasStatCards}, Errors=${result.hasErrors}`);
  });

  return results;
}

// 运行测试
testPages().catch(console.error);
