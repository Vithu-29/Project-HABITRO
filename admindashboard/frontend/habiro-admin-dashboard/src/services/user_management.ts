import axios from "@/lib/axios";

export async function getUserManagementData() {
  const response = await axios.get('/user-management/');
  return response.data;
}

export async function sendEmailToUser(email: string, subject: string, message: string) {
  const response = await axios.post('/send-email/', { email, subject, message });
  return response.data;
}
export async function suspendUserById(userId: number) {
  const response = await axios.post('/suspend-user/', { user_id: userId });
  return response.data;
}
