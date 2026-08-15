/**
 * 解析上传返回值为图片 URL（后端直接返回 URL 字符串；偶发 Result/axios 包装时再拆一层）
 */
export function resolveUploadUrl(res) {
  if (res == null) return ''
  if (typeof res === 'string') {
    const text = res.trim()
    if (!text) return ''
    // 纯 URL
    if (/^https?:\/\//.test(text)) return text
    // 偶发 JSON 字符串
    if ((text.startsWith('{') && text.endsWith('}')) || (text.startsWith('"') && text.endsWith('"'))) {
      try {
        return resolveUploadUrl(JSON.parse(text))
      } catch {
        return text
      }
    }
    return text
  }
  if (typeof res === 'object') {
    if (typeof res.data === 'string' && res.data) return resolveUploadUrl(res.data)
    if (typeof res.url === 'string' && res.url) return res.url
    if (res.response) return resolveUploadUrl(res.response)
  }
  return ''
}
