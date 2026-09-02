package games.tapped.play.notification;

final class RefDecisionEmailTemplate {

    private RefDecisionEmailTemplate() {
    }

    static String subject(String subjectPrefix) {
        return subjectPrefix + " | Final Call Needed";
    }

    static String render(
            String title,
            String contents,
            String finalCallUrl,
            int expiresInHours
    ) {
        String safeTitle = escapeHtml(title);
        String safeContents = escapeHtml(contents);
        String safeFinalCallUrl = escapeHtml(finalCallUrl);
        String expiryLabel = escapeHtml(formatExpiryText(expiresInHours));

        return """
                <!doctype html>
                <html>
                  <body style="margin:0; padding:0; background:#f6f7f9;">
                    <div style="display:none; max-height:0; overflow:hidden; opacity:0; color:transparent;">
                      Review this play and make the final call.
                    </div>
                    <table role="presentation" width="100%%" cellpadding="0" cellspacing="0" style="background:#f6f7f9; margin:0; padding:24px 0;">
                      <tr>
                        <td align="center">
                          <table role="presentation" width="100%%" cellpadding="0" cellspacing="0" style="max-width:600px; margin:0 auto;">
                            <tr>
                              <td style="padding:0 16px;">
                                <table role="presentation" width="100%%" cellpadding="0" cellspacing="0" style="background:#ffffff; border:1px solid #ececf2; border-radius:20px; overflow:hidden; box-shadow:0 6px 24px rgba(17,24,39,0.06);">
                                  <tr>
                                    <td style="padding:0;">
                                      <div style="height:6px; background:linear-gradient(90deg, #16a34a 0%%, #22c55e 35%%, #a855f7 100%%);"></div>
                                    </td>
                                  </tr>
                                  <tr>
                                    <td style="padding:28px 28px 10px 28px; font-family:Arial,Helvetica,sans-serif; color:#111827;">
                                      <h1 style="margin:0; font-size:28px; line-height:1.2; font-weight:700;">%s</h1>
                                    </td>
                                  </tr>
                                  <tr>
                                    <td style="padding:12px 28px 0 28px; font-family:Arial,Helvetica,sans-serif; color:#374151;">
                                      <p style="margin:0; font-size:15px; line-height:1.7; white-space:pre-line;">%s</p>
                                    </td>
                                  </tr>
                                  <tr>
                                    <td style="padding:22px 28px 0 28px; font-family:Arial,Helvetica,sans-serif; color:#111827;">
                                      <p style="margin:0; font-size:15px; line-height:1.6; font-weight:600;">Review the play and make the final call.</p>
                                    </td>
                                  </tr>
                                  <tr>
                                    <td style="padding:18px 28px 0 28px;">
                                      <table role="presentation" cellpadding="0" cellspacing="0">
                                        <tr>
                                          <td align="center" style="border-radius:12px; background:#111827;">
                                            <a href="%s" style="display:inline-block; padding:14px 22px; font-family:Arial,Helvetica,sans-serif; font-size:15px; font-weight:700; line-height:1; color:#ffffff; text-decoration:none; border-radius:12px;">Open Final Call</a>
                                          </td>
                                        </tr>
                                      </table>
                                    </td>
                                  </tr>
                                  <tr>
                                    <td style="padding:18px 28px 0 28px;">
                                      <div style="border-radius:16px; background:#fafafc; border:1px solid #ececf2; padding:14px 16px; font-family:Arial,Helvetica,sans-serif;">
                                        <p style="margin:0; font-size:13px; line-height:1.6; color:#4b5563;">Anyone with this link can review and decide. Share only with people you trust, and avoid sensitive personal information.</p>
                                      </div>
                                    </td>
                                  </tr>
                                  <tr>
                                    <td style="padding:18px 28px 28px 28px; font-family:Arial,Helvetica,sans-serif;">
                                      <p style="margin:0; font-size:12px; line-height:1.6; color:#6b7280;">This link is valid for %s. If you didn’t expect this email, you can ignore it.</p>
                                    </td>
                                  </tr>
                                </table>
                              </td>
                            </tr>
                          </table>
                        </td>
                      </tr>
                    </table>
                  </body>
                </html>
                """.formatted(safeTitle, safeContents, safeFinalCallUrl, expiryLabel);
    }

    private static String formatExpiryText(int expiresInHours) {
        if (expiresInHours % 24 == 0) {
            int days = expiresInHours / 24;
            return days + " day" + (days > 1 ? "s" : "");
        }
        return expiresInHours + " hour" + (expiresInHours > 1 ? "s" : "");
    }

    private static String escapeHtml(String value) {
        if (value == null) {
            return "";
        }
        return value
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
}
