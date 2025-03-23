import * as Icons from "../icons";

export const NAV_DATA = [
  {
    label: "MAIN MENU",
    items: [
      {
        title: "Dashboard",
        icon: Icons.HomeIcon,
        url: "/",
        items: [
],
      },
      {
        title: "User management",
        url: "/profile",
        icon: Icons.User,
        items: [],
      },
      {
        title: "Habit management",
        url: "/habitmanagement",
        icon: Icons.Calendar,
        items: [],
      },

      {
        title: "Analytics",
        icon: Icons.PieChart,
        url: "/charts/analytics",
        items: [],

      },
      {
        title: "Blog management",
        icon: Icons.Alphabet,
        url: "/blogs",
        items: [],
      },
      {
        title: "Settings",
        icon: Icons.Settingsicons,
        items: [],
      },

    ],
  },
  {

    items: [

       
      {
        title: "Logout",
        icon: Icons.Authentication,
         url: "/auth/sign-in",
         items:[],
      },
    ],
  },
];
