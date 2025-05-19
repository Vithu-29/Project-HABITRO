import axios from "@/lib/axios"; 



export async function getDevicesUsedData(timeFrame?: "monthly" | "yearly" | (string & {})) {
  try {
    const response = await axios.get('used-devices-data/', {
      params: timeFrame ? { timeFrame } : {}
    });
    return response.data;
  } catch (error) {
    console.error('Error fetching devices used data:', error);
    throw new Error('Failed to fetch devices used data');
  }
}

//Active Users Chart
export async function getCampaignVisitorsData() {
  try {
    const response = await axios.get('active-users-chart/'); 
    return response.data;
  } catch (error) {
    console.error('Error fetching active users chart:', error);
    throw new Error('Failed to fetch active users chart');
  }
}



