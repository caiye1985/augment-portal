// src/services/uiApi.js

/**
 * 模拟一个前端UI结构化数据API服务。
 * 实际应用中，这会是一个后端API，或者是一个在构建时生成UI结构的服务。
 */

/**
 * 将Vue组件实例转换为结构化数据。
 * 这是一个简化的示例，实际转换会更复杂，需要考虑组件的props, slots, events等。
 * @param {VueComponent} componentInstance - Vue组件实例。
 * @returns {Object} 结构化UI数据。
 */
export function getUIStructure(componentInstance) {
  if (!componentInstance || !componentInstance.$el) {
    return null;
  }

  const traverse = (vm) => {
    if (!vm || !vm.$el) {
      return null;
    }

    const tagName = vm.$el.tagName ? vm.$el.tagName.toLowerCase() : 'unknown';
    const attributes = {};
    if (vm.$el.attributes) {
      Array.from(vm.$el.attributes).forEach(attr => {
        attributes[attr.name] = attr.value;
      });
    }

    const children = [];
    if (vm.$children && vm.$children.length > 0) {
      vm.$children.forEach(child => {
        const childStructure = traverse(child);
        if (childStructure) {
          children.push(childStructure);
        }
      });
    } else if (vm.$el.children && vm.$el.children.length > 0) {
      // Fallback for non-Vue components (e.g., plain HTML elements within a component's template)
      Array.from(vm.$el.children).forEach(domChild => {
        // Only include if it's an element node
        if (domChild.nodeType === 1) {
          const childAttributes = {};
          Array.from(domChild.attributes).forEach(attr => {
            childAttributes[attr.name] = attr.value;
          });
          children.push({
            name: domChild.tagName.toLowerCase(),
            attributes: childAttributes,
            children: [] // Simplified: not traversing deeper into plain DOM elements for this example
          });
        }
      });
    }

    return {
      name: vm.$options.__file || tagName, // Use component file name if available, otherwise tag name
      tagName: tagName,
      attributes: attributes,
      props: vm.$props ? { ...vm.$props } : {},
      data: vm.$data ? { ...vm.$data } : {},
      children: children,
      text: vm.$el.textContent ? vm.$el.textContent.trim().substring(0, 100) + '...' : '' // Capture some text content
    };
  };

  return traverse(componentInstance);
}

/**
 * 模拟API调用，获取指定组件的结构化数据。
 * @param {VueComponent} componentInstance - 要获取结构化数据的Vue组件实例。
 * @returns {Promise<Object>} 包含UI结构数据的Promise。
 */
export function fetchUIStructure(componentInstance) {
  return new Promise((resolve) => {
    setTimeout(() => {
      const structure = getUIStructure(componentInstance);
      resolve({
        status: 'success',
        data: structure,
        message: 'UI structure fetched successfully.'
      });
    }, 500); // 模拟网络延迟
  });
}