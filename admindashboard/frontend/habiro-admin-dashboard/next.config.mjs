/** @type {import("next").NextConfig} */
const nextConfig = {
  images: {
    domains: [
      "localhost",
      "127.0.0.1", 
      "randomuser.me",
      "api.dicebear.com", 
      
    ],
    remotePatterns: [
      { protocol: "https", hostname: "cdn.sanity.io", port: "" },
      { protocol: "https", hostname: "lh3.googleusercontent.com", port: "" },
      { protocol: "https", hostname: "avatars.githubusercontent.com", port: "" },
      { protocol: "https", hostname: "pub-b7fd9c30cdbf439183b75041f5f71b92.r2.dev", port: "" },
      {
        protocol: 'https',
        hostname: 'www.bing.com',
      },
      {
        protocol: 'https',
        hostname: 'd27jswm5an3efw.cloudfront.net', // also needed if you use this directly
      },
    ]
  }
};

export default nextConfig;
