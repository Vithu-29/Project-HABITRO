// usersData.ts
import { User } from "./types";

const usersData = [
  {
    id: 1,
    name: "Scarlett Johansson",
    email: "example@gmail.com",
    joined: "19 Jan, 2024",
    completionRate: "82%",
    profilePicture: "/images/user/user-03.png",
    isActive: true,  
    goodHabits: [
      "Exercises daily for 30 minutes",
      "Reads self-improvement books regularly",
      "Maintains a consistent sleep schedule",
    ],
    badHabits: [
      "Procrastinates on work deadlines",
      "Spends too much time on social media",
      "Drinks excessive coffee daily",
    ],
    screenTime: [2, 3, 1, 5, 4, 6, 3],
    tasks: { completed: 70, pending: 30 },
  },
  {
    id: 2,
    name: "John Doe",
    email: "john@example.com",
    joined: "22 Feb, 2024",
    completionRate: "90%",
    profilePicture: "/images/user/user-03.png",
    isActive: false,  
    goodHabits: ["Meditates every morning", "Reads at least one book per month", "Maintains a healthy diet"],
    badHabits: ["Overworks without breaks", "Forgets to stay hydrated", "Sleeps late at night"],
    screenTime: [1, 2, 3, 2, 4, 1, 3],
    tasks: { completed: 85, pending: 15 },
  },
];

export default usersData;
