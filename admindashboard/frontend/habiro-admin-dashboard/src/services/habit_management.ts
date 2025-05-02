import axios from "@/lib/axios";

export async function getHabitOverview() {
  const res = await axios.get("/habit-overview/");
  return res.data;
}

export async function getHabitTypeOverview() {
  const res = await axios.get("/habit-type-overview/");
  return res.data;
}

export async function getGoodHabitAnalytics() {
    const res = await axios.get("/good-habit-analytics/");
    return res.data;
  }
    
export async function getCompletedUsersByHabit(habitId: number) {
    const res = await axios.get(`/good-habit-analytics/${habitId}/users/`);
    return res.data;
  }
  