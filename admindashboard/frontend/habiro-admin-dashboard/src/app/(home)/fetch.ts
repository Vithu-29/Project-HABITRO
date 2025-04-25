export async function getOverviewData() {
  await new Promise((resolve) => setTimeout(resolve, 2000));

  return {
    views: {
      value: 40684,
      growthRate: 8.5,
    },
    profit: {
      value: 57,
      growthRate: 1.35,
    },
    products: {
      value: 10000,
      growthRate: -4.3,
    },
    users: {
      value: 200,
      growthRate: 1.95,
    },
  };
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
