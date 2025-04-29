// src/app/(home)/fetch.ts
import axios from "@/lib/axios"; // ← import your axios instance

export async function getOverviewData() {
  try {
    const response = await axios.get('dashboard-overview/'); // no need full URL
    return response.data; // Axios returns {data, status, ...}
  } catch (error) {
    console.error('Error fetching overview data:', error);
    throw new Error('Failed to fetch overview data');
  }
}



// Simulates a delay and returns mock chat data
export async function getChatsData() {
  await new Promise((resolve) => setTimeout(resolve, 1000));

  return [
    {
      name: "John Doe",
      profile: "/avatars/user1.png", // Make sure these images exist in your public folder
      isActive: true,
      unreadCount: 3,
      lastMessage: {
        content: "Hey! How are you?",
        timestamp: new Date().toISOString(),
      },
    },
    {
      name: "Jane Smith",
      profile: "/avatars/user2.png",
      isActive: false,
      unreadCount: 0,
      lastMessage: {
        content: "Meeting at 5pm.",
        timestamp: new Date(Date.now() - 3600 * 1000).toISOString(), // 1 hour ago
      },
    },
    {
      name: "Michael Lee",
      profile: "/avatars/user3.png",
      isActive: true,
      unreadCount: 1,
      lastMessage: {
        content: "Sent you the report.",
        timestamp: new Date(Date.now() - 2 * 3600 * 1000).toISOString(), // 2 hours ago
      },
    },
  ];
}
