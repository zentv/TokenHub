import type { NextConfig } from "next";

// TOKENHUB_STATIC_EXPORT=1 builds a dependency-free static bundle for hosts
// without a Node runtime (e.g. OpenWrt routers). Default stays "standalone".
const staticExport = process.env.TOKENHUB_STATIC_EXPORT === "1";

const nextConfig: NextConfig = {
  reactStrictMode: true,
  output: staticExport ? "export" : "standalone",
  // Emit <route>/index.html so plain file servers (uhttpd, nginx) resolve
  // deep links without rewrite rules.
  trailingSlash: staticExport,
  allowedDevOrigins: ["127.0.0.1", "localhost"],
};

export default nextConfig;
