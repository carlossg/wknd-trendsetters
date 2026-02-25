/**
 * loads and decorates the accordion block
 * @param {Element} block The accordion block element
 */
export default function decorate(block) {
  const rows = [...block.children];
  if (!rows.length) return;

  // First row is the header (title + description)
  const headerRow = rows.shift();
  const headerDiv = document.createElement('div');
  headerDiv.className = 'accordion-header';
  headerDiv.append(...headerRow.childNodes);
  headerRow.remove();

  const container = document.createElement('div');
  container.className = 'accordion-items';

  rows.forEach((row) => {
    const cols = [...row.children];
    const question = cols[0]?.textContent?.trim() || '';
    const answerContent = cols[1] || cols[0];

    const details = document.createElement('details');
    const summary = document.createElement('summary');
    summary.textContent = question;

    const answer = document.createElement('div');
    answer.className = 'accordion-answer';
    if (cols.length > 1 && answerContent) {
      answer.append(...answerContent.childNodes);
    }

    details.append(summary, answer);
    container.append(details);
    row.remove();
  });

  block.textContent = '';
  block.append(headerDiv, container);
}
