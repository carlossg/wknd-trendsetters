/**
 * loads and decorates the hero block
 * @param {Element} block The hero block element
 */
export default function decorate(block) {
  const rows = [...block.children];

  // Detect layout: single row with 2 cells = split layout (text + images side by side)
  if (rows.length === 1) {
    const cells = [...rows[0].children];
    if (cells.length === 2) {
      const hasText = cells[0].querySelector('h1, h2, h3');
      const hasImages = cells[1].querySelector('picture');
      if (hasText && hasImages) {
        block.classList.add('hero-split');
        cells[0].classList.add('hero-content');
        cells[1].classList.add('hero-images');
        return;
      }
      // Check reverse: images first, text second
      const hasTextR = cells[1].querySelector('h1, h2, h3');
      const hasImagesR = cells[0].querySelector('picture');
      if (hasTextR && hasImagesR) {
        block.classList.add('hero-split');
        cells[1].classList.add('hero-content');
        cells[0].classList.add('hero-images');
        return;
      }
    }
  }

  // Full-bleed background layout: separate image rows from content rows
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
