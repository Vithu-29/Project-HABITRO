// types.ts
export interface User {
    id: number;
    name: string;
    email: string;
    joined: string;
    completionRate: string;
    profilePicture: string;
    isActive: boolean;
    goodHabits: string[];
    badHabits: string[];
    screenTime: number[];
    tasks: {
      completed: number;
      pending: number;
    };
  }
  