import axios from "@/lib/axios"; 

export async function getRecentUsersData() {
  try {
    const response = await axios.get('recent-users/');
    return response.data;
  } catch (error) {
    console.error('Error fetching recent users:', error);
    throw new Error('Failed to fetch recent users');
  }
}
