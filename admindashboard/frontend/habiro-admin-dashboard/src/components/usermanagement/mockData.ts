export interface User {
    id: string;
    name: string;
    email: string;
    joinedDate: string;
    completionRate: number;
    profilePicture: string;
    goodHabits: string[];
    badHabits: string[];
    screenTimeData: number[];
    taskCompletion: { finished: number; pending: number };
  }
  
  export const users: User[] = [
    {
      id: "1",
      name: "Scarlett Johansson",
      email: "example@gmail.com",
      joinedDate: "19 Jan, 2024",
      completionRate: 82,
      profilePicture: "/profile-pic.jpg",
      goodHabits: [
        "Exercises daily for 30 minutes.",
        "Reads self-improvement books regularly.",
        "Maintains a consistent sleep schedule.",
      ],
      badHabits: [
        "Procrastinates on work deadlines.",
        "Spends too much time on social media.",
        "Drinks excessive coffee daily.",
      ],
      screenTimeData: [2, 3, 4, 5, 6, 3, 2], // Daily screen time in hours
      taskCompletion: { finished: 30, pending: 10 },
    },
  ];
  