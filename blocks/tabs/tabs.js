function generateId(text) {
  return text.trim().toLowerCase().replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '');
}

/**
 * loads and decorates the tabs block
 * @param {Element} block The tabs block element
 */
export default function decorate(block) {
  const rows = [...block.children];
  if (!rows.length) return;

  const tablist = document.createElement('div');
  tablist.className = 'tabs-list';
  tablist.setAttribute('role', 'tablist');

  const panels = document.createElement('div');
  panels.className = 'tabs-panels';

  rows.forEach((row, i) => {
    const cols = [...row.children];
    const label = cols[0]?.textContent?.trim() || `Tab ${i + 1}`;
    const content = cols[1] || cols[0];
    const id = generateId(label);

    // create tab button
    const tab = document.createElement('button');
    tab.className = 'tabs-tab';
    tab.setAttribute('role', 'tab');
    tab.setAttribute('aria-selected', i === 0 ? 'true' : 'false');
    tab.setAttribute('aria-controls', `panel-${id}`);
    tab.setAttribute('id', `tab-${id}`);
    tab.setAttribute('tabindex', i === 0 ? '0' : '-1');
    tab.textContent = label;
    tablist.append(tab);

    // create panel
    const panel = document.createElement('div');
    panel.className = 'tabs-panel';
    panel.setAttribute('role', 'tabpanel');
    panel.setAttribute('id', `panel-${id}`);
    panel.setAttribute('aria-labelledby', `tab-${id}`);
    panel.hidden = i !== 0;

    if (cols.length > 1 && content) {
      panel.append(...content.childNodes);
    } else if (content) {
      panel.append(...content.childNodes);
    }

    panels.append(panel);
    row.remove();
  });

  // keyboard navigation
  tablist.addEventListener('keydown', (e) => {
    const tabs = [...tablist.querySelectorAll('[role="tab"]')];
    const current = tabs.indexOf(e.target);
    let next;

    switch (e.key) {
      case 'ArrowRight':
        next = (current + 1) % tabs.length;
        break;
      case 'ArrowLeft':
        next = (current - 1 + tabs.length) % tabs.length;
        break;
      case 'Home':
        next = 0;
        break;
      case 'End':
        next = tabs.length - 1;
        break;
      default:
        return;
    }

    e.preventDefault();
    tabs[next].focus();
    tabs[next].click();
  });

  // click handler
  tablist.addEventListener('click', (e) => {
    const clicked = e.target.closest('[role="tab"]');
    if (!clicked) return;

    const tabs = [...tablist.querySelectorAll('[role="tab"]')];
    const allPanels = [...panels.querySelectorAll('[role="tabpanel"]')];

    tabs.forEach((tab) => {
      tab.setAttribute('aria-selected', 'false');
      tab.setAttribute('tabindex', '-1');
    });

    allPanels.forEach((panel) => {
      panel.hidden = true;
    });

    clicked.setAttribute('aria-selected', 'true');
    clicked.setAttribute('tabindex', '0');

    const targetPanel = panels.querySelector(`#${clicked.getAttribute('aria-controls')}`);
    if (targetPanel) targetPanel.hidden = false;
  });

  block.textContent = '';
  block.append(tablist, panels);
}
