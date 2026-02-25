/**
 * loads and decorates the hero block
 * @param {Element} block The hero block element
 */
export default function decorate(block) {
  const rows = [...block.children];
  const bgContainer = document.createElement('div');
  bgContainer.className = 'hero-bg';

  const contentContainer = document.createElement('div');
  contentContainer.className = 'hero-content';

  rows.forEach((row) => {
    const hasOnlyPicture = row.querySelector('picture')
      && !row.textContent.trim();

    if (hasOnlyPicture) {
      bgContainer.append(...row.childNodes);
      row.remove();
    } else {
      contentContainer.append(...row.childNodes);
      row.remove();
    }
  });

  if (bgContainer.children.length) {
    block.prepend(bgContainer);
  }

  block.append(contentContainer);
}
