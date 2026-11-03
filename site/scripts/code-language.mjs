import hljs from 'highlight.js';

const CANDIDATES = ['java', 'csharp', 'javascript', 'typescript', 'json', 'xml', 'yaml', 'bash', 'powershell', 'sql', 'css', 'dockerfile', 'python', 'kotlin'];
const MIN_RELEVANCE = 5;

// ✅ 후보 언어를 제한하고 신뢰도가 낮으면 text를 반환해 오탐 색상을 막는다.
export function detectCodeLanguage(code) {
  const { language, relevance } = hljs.highlightAuto(code, CANDIDATES);
  return language && relevance >= MIN_RELEVANCE ? language : 'text';
}
