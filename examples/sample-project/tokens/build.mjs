// tokens/tokens.json'dan üretir (K-014; tasarım kuralı 1):
//   tokens/build/tokens.css  web CSS değişkenleri, color-scheme: light
//   tokens/build/theme.ts    mobil tema
//   tokens/build/email.json  e-posta şablonu sabitleri
//   DESIGN.md                "tokens:start" ile "tokens:end" arasındaki tablo
// Bağımlılık yok; Node 20 ve üstü.
//   node tokens/build.mjs          üretir
//   node tokens/build.mjs --check  yeniden üretir, diskteki dosyayla
//                                  karşılaştırır ve kontrastı ölçer;
//                                  fark ya da düşük kontrast varsa çıkış 1
import { readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const root = join(here, "..");
const src = JSON.parse(readFileSync(join(here, "tokens.json"), "utf8"));
const check = process.argv.includes("--check");
const HEADER = "Üretildi: tokens/build.mjs. Elle değiştirme. Kaynak: tokens/tokens.json";

// Token ağacını düzleştir: [{path: ["color","ink"], type, value, description}]
function flatten(node, path = [], inherited) {
  const out = [];
  const type = node.$type ?? inherited;
  for (const [key, child] of Object.entries(node)) {
    if (key.startsWith("$")) continue;
    if (child && typeof child === "object" && "$value" in child) {
      out.push({ path: [...path, key], type: child.$type ?? type, value: child.$value, description: child.$description ?? "" });
    } else if (child && typeof child === "object") {
      out.push(...flatten(child, [...path, key], type));
    }
  }
  return out;
}

function cssValue(t) {
  if (t.type === "color") return t.value.hex.toLowerCase();
  if (t.type === "dimension") return `${t.value.value}${t.value.unit}`;
  if (t.type === "fontFamily") return [].concat(t.value).join(", ");
  return String(t.value);
}

function jsValue(t) {
  if (t.type === "color") return t.value.hex.toLowerCase();
  if (t.type === "dimension") return t.value.value;
  if (t.type === "fontFamily") return [].concat(t.value)[0];
  return t.value;
}

const tokens = flatten(src);
const cssName = (p) => `--${p.join("-")}`;
const camel = (s) => s.replace(/-([a-z0-9])/g, (_, c) => c.toUpperCase());

function buildCss() {
  const lines = [`/* ${HEADER} */`, ":root {", "  color-scheme: light;"];
  for (const t of tokens) lines.push(`  ${cssName(t.path)}: ${cssValue(t)};`);
  lines.push("}", "");
  return lines.join("\n");
}

function nest(selectTokens) {
  const obj = {};
  for (const t of selectTokens) {
    let cur = obj;
    t.path.slice(0, -1).forEach((k) => (cur = cur[camel(k)] ??= {}));
    cur[camel(t.path.at(-1))] = jsValue(t);
  }
  return obj;
}

function buildTheme() {
  const body = JSON.stringify(nest(tokens), null, 2).replace(/"([A-Za-z_][A-Za-z0-9_]*)":/g, "$1:");
  return `// ${HEADER}\n// Yalnız açık tema (K-014).\nexport const theme = ${body} as const;\n\nexport type Theme = typeof theme;\n`;
}

function buildEmail() {
  const pick = tokens.filter((t) => t.path[0] === "color" || (t.path[0] === "font" && t.path[1] === "family"));
  return JSON.stringify({ $comment: HEADER, ...nest(pick) }, null, 2) + "\n";
}

function buildDesignTable() {
  const rows = ["| Rol | Token | Değer | Kullanım | Karar |", "|---|---|---|---|---|"];
  for (const t of tokens.filter((t) => t.path[0] === "color")) {
    rows.push(`| ${t.path.at(-1)} | ${cssName(t.path)} | ${cssValue(t)} | ${t.description} | K-014 |`);
  }
  return rows.join("\n");
}

// WCAG 2.2 kontrastı (tasarım kuralı 7).
function lum(hex) {
  const c = [1, 3, 5].map((i) => parseInt(hex.slice(i, i + 2), 16) / 255)
    .map((v) => (v <= 0.04045 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4));
  return 0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2];
}
function ratio(a, b) {
  const [x, y] = [lum(a), lum(b)].sort((m, n) => n - m);
  return (x + 0.05) / (y + 0.05);
}
const hex = (name) => tokens.find((t) => t.path[0] === "color" && t.path[1] === name).value.hex;
const PAIRS = [
  ["ink", "surface", 4.5], ["ink", "surface-muted", 4.5],
  ["ink-muted", "surface", 4.5], ["ink-muted", "surface-muted", 4.5],
  ["on-accent", "accent", 4.5], ["accent", "surface", 4.5],
  ["line", "surface", 3], ["focus", "surface", 3],
  ["success", "surface", 4.5], ["on-success-bg", "success-bg", 4.5],
  ["warning", "surface", 4.5], ["on-warning-bg", "warning-bg", 4.5],
  ["danger", "surface", 4.5], ["on-danger-bg", "danger-bg", 4.5],
];

const designPath = join(root, "DESIGN.md");
const START = "<!-- tokens:start -->";
const END = "<!-- tokens:end -->";
function withTable(md) {
  const a = md.indexOf(START);
  const b = md.indexOf(END);
  if (a < 0 || b < a) throw new Error("DESIGN.md'de tokens:start / tokens:end işareti yok");
  return md.slice(0, a + START.length) + "\n" + buildDesignTable() + "\n" + md.slice(b);
}

const outputs = [
  [join(here, "build", "tokens.css"), buildCss()],
  [join(here, "build", "theme.ts"), buildTheme()],
  [join(here, "build", "email.json"), buildEmail()],
  [designPath, withTable(readFileSync(designPath, "utf8"))],
];

if (check) {
  let fail = 0;
  for (const [file, content] of outputs) {
    let disk = "";
    try { disk = readFileSync(file, "utf8"); } catch { /* yok */ }
    if (disk !== content) { console.error(`FARK: ${file.slice(root.length + 1)} yeniden üretilmeli`); fail = 1; }
  }
  for (const [fg, bg, min] of PAIRS) {
    const r = ratio(hex(fg), hex(bg));
    const ok = r >= min;
    if (!ok) fail = 1;
    console.log(`${ok ? "tamam" : "DÜŞÜK"}: ${fg} / ${bg} ${r.toFixed(2)}:1 (en az ${min}:1)`);
  }
  console.log(fail ? "token denetimi GEÇMEDİ" : "token denetimi geçti: üretilen dosyalarda fark yok");
  process.exit(fail);
} else {
  mkdirSync(join(here, "build"), { recursive: true });
  for (const [file, content] of outputs) writeFileSync(file, content);
  console.log(`${outputs.length} dosya üretildi.`);
}
