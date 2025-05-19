// src/app/(home)/fetch.ts
import axios from "@/lib/axios"; // ← import your axios instance

export async function getOverviewData() {
  try {
    const response = await axios.get('dashboard-overview/'); 
    return response.data; // Axios returns {data, status, ...}
  } catch (error) {
    console.error('Error fetching overview data:', error);
    throw new Error('Failed to fetch overview data');
  }
}

