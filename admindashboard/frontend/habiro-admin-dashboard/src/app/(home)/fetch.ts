export async function getOverviewData() {
  // Fake delay
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

