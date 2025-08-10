/**
 * 深色模式强制修复工具
 * 用于强制修复顽固的白色背景问题
 */

export class DarkModeForcer {
  constructor() {
    this.observer = null;
    this.isActive = false;
  }

  /**
   * 启动深色模式强制修复
   */
  start() {
    if (this.isActive) return;
    
    this.isActive = true;
    this.forceFixWhiteBackgrounds();
    this.startObserver();
    
    console.log('🌙 深色模式强制修复已启动');
  }

  /**
   * 停止深色模式强制修复
   */
  stop() {
    if (!this.isActive) return;
    
    this.isActive = false;
    if (this.observer) {
      this.observer.disconnect();
      this.observer = null;
    }
    
    console.log('🌙 深色模式强制修复已停止');
  }

  /**
   * 强制修复所有白色背景
   */
  forceFixWhiteBackgrounds() {
    const isDarkMode = document.documentElement.getAttribute('data-theme') === 'dark';
    if (!isDarkMode) return;

    // 强制修复Element Plus组件
    this.fixElementPlusComponents();
    
    // 强制修复自定义组件
    this.fixCustomComponents();
    
    // 强制修复内联样式
    this.fixInlineStyles();
  }

  /**
   * 修复Element Plus组件
   */
  fixElementPlusComponents() {
    const components = [
      // 选择器组件
      '.el-select__wrapper',
      '.el-select .el-input__wrapper',
      
      // 卡片组件
      '.el-card',
      '.el-card__header',
      '.el-card__body',
      
      // 标签页组件
      '.el-tabs',
      '.el-tabs__header',
      '.el-tabs__nav-wrap',
      '.el-tabs__content',
      '.el-tab-pane',
      
      // 树形组件
      '.el-tree',
      '.el-tree-node__content',
      
      // 表格组件
      '.el-table',
      '.el-table th',
      '.el-table td',
      
      // 输入框组件
      '.el-input__wrapper',
      '.el-textarea__inner',
      
      // 表单组件
      '.el-form-item',
      '.el-form-item__content'
    ];

    components.forEach(selector => {
      const elements = document.querySelectorAll(selector);
      elements.forEach(element => {
        this.applyDarkStyles(element);
      });
    });
  }

  /**
   * 修复自定义组件
   */
  fixCustomComponents() {
    const customComponents = [
      '.stat-card',
      '.stats-container',
      '.page-header',
      '.content-container',
      '.demo-container',
      '.engineer-card',
      '.task-card',
      '.message-card'
    ];

    customComponents.forEach(selector => {
      const elements = document.querySelectorAll(selector);
      elements.forEach(element => {
        this.applyDarkStyles(element);
      });
    });
  }

  /**
   * 修复内联样式
   */
  fixInlineStyles() {
    // 查找所有具有白色背景的元素
    const allElements = document.querySelectorAll('*');
    
    allElements.forEach(element => {
      const computedStyle = window.getComputedStyle(element);
      const bgColor = computedStyle.backgroundColor;
      
      // 检查是否为白色背景
      if (bgColor === 'rgb(255, 255, 255)' || 
          bgColor === '#ffffff' || 
          bgColor === 'white') {
        this.applyDarkStyles(element);
      }
    });
  }

  /**
   * 应用深色样式
   */
  applyDarkStyles(element) {
    if (!element) return;

    // 设置深色背景
    element.style.setProperty('background-color', '#1e293b', 'important');
    
    // 设置文字颜色
    const textColor = window.getComputedStyle(element).color;
    if (textColor === 'rgb(0, 0, 0)' || 
        textColor === '#000000' || 
        textColor === 'black' ||
        textColor === 'rgb(48, 49, 51)') {
      element.style.setProperty('color', '#f8fafc', 'important');
    }
    
    // 设置边框颜色
    element.style.setProperty('border-color', '#334155', 'important');
  }

  /**
   * 启动DOM观察器
   */
  startObserver() {
    if (this.observer) return;

    this.observer = new MutationObserver((mutations) => {
      if (!this.isActive) return;

      let needsUpdate = false;
      
      mutations.forEach((mutation) => {
        if (mutation.type === 'childList') {
          mutation.addedNodes.forEach((node) => {
            if (node.nodeType === Node.ELEMENT_NODE) {
              needsUpdate = true;
            }
          });
        } else if (mutation.type === 'attributes') {
          if (mutation.attributeName === 'style' || 
              mutation.attributeName === 'class') {
            needsUpdate = true;
          }
        }
      });

      if (needsUpdate) {
        // 延迟执行，避免频繁更新
        setTimeout(() => {
          this.forceFixWhiteBackgrounds();
        }, 100);
      }
    });

    this.observer.observe(document.body, {
      childList: true,
      subtree: true,
      attributes: true,
      attributeFilter: ['style', 'class']
    });
  }

  /**
   * 检查并修复特定元素
   */
  checkAndFixElement(element) {
    if (!this.isActive) return;
    if (!element || element.nodeType !== Node.ELEMENT_NODE) return;

    const isDarkMode = document.documentElement.getAttribute('data-theme') === 'dark';
    if (!isDarkMode) return;

    const computedStyle = window.getComputedStyle(element);
    const bgColor = computedStyle.backgroundColor;
    
    if (bgColor === 'rgb(255, 255, 255)' || 
        bgColor === '#ffffff' || 
        bgColor === 'white') {
      this.applyDarkStyles(element);
    }

    // 递归检查子元素
    element.querySelectorAll('*').forEach(child => {
      const childStyle = window.getComputedStyle(child);
      const childBgColor = childStyle.backgroundColor;
      
      if (childBgColor === 'rgb(255, 255, 255)' || 
          childBgColor === '#ffffff' || 
          childBgColor === 'white') {
        this.applyDarkStyles(child);
      }
    });
  }
}

// 创建全局实例
export const darkModeForcer = new DarkModeForcer();

// 监听主题变化
export function initDarkModeForcer() {
  // 监听主题变化
  const observer = new MutationObserver((mutations) => {
    mutations.forEach((mutation) => {
      if (mutation.type === 'attributes' && 
          mutation.attributeName === 'data-theme') {
        const isDarkMode = document.documentElement.getAttribute('data-theme') === 'dark';
        
        if (isDarkMode) {
          setTimeout(() => {
            darkModeForcer.start();
          }, 500); // 延迟启动，确保主题切换完成
        } else {
          darkModeForcer.stop();
        }
      }
    });
  });

  observer.observe(document.documentElement, {
    attributes: true,
    attributeFilter: ['data-theme']
  });

  // 初始检查
  const isDarkMode = document.documentElement.getAttribute('data-theme') === 'dark';
  if (isDarkMode) {
    setTimeout(() => {
      darkModeForcer.start();
    }, 1000);
  }
}

// 导出便捷方法
export function forceDarkMode() {
  darkModeForcer.start();
}

export function stopForceDarkMode() {
  darkModeForcer.stop();
}
