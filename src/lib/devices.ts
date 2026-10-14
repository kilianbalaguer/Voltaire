export type Platform = {
  id: string;
  name: string;
  icon: string;
  status: "launch" | "later";
  note: string;
  supported: string[];
  unsupported: string[];
};

export const platforms: Platform[] = [
  {
    id: "iphone",
    name: "iPhone",
    icon: "fa-solid fa-mobile-screen",
    status: "launch",
    note: "Voltaire launches on iPhone 13 and later.",
    supported: [
      "iPhone 13 mini", "iPhone 13", "iPhone 13 Pro", "iPhone 13 Pro Max",
      "iPhone 14", "iPhone 14 Plus", "iPhone 14 Pro", "iPhone 14 Pro Max",
      "iPhone 15", "iPhone 15 Plus", "iPhone 15 Pro", "iPhone 15 Pro Max",
      "iPhone 16", "iPhone 16 Plus", "iPhone 16e", "iPhone 16 Pro", "iPhone 16 Pro Max",
      "iPhone 17", "iPhone 17 Air", "iPhone 17e", "iPhone 17 Pro", "iPhone 17 Pro Max",
    ],
    unsupported: [
      "iPhone X or earlier", "iPhone XS", "iPhone XS Max", "iPhone XR",
      "iPhone 11", "iPhone 11 Pro", "iPhone 11 Pro Max",
      "iPhone 12 mini", "iPhone 12", "iPhone 12 Pro", "iPhone 12 Pro Max",
      "iPhone SE (1st gen)", "iPhone SE (2nd gen)", "iPhone SE (3rd gen)",
    ],
  },
  {
    id: "ipad",
    name: "iPad",
    icon: "fa-solid fa-tablet-screen-button",
    status: "later",
    note: "iPad support is planned after the iPhone launch.",
    supported: [
      "iPad Pro (M1)", "iPad Pro (M2)", "iPad Pro (M4)",
      "iPad Air (M1)", "iPad Air (M2)", "iPad Air (M3)", "iPad mini (A17 Pro)",
    ],
    unsupported: [
      "iPad (1st-9th gen)", "iPad (10th gen)", "iPad Pro (pre-M1)",
      "iPad Air (pre-M1)", "iPad mini (pre-A17)",
    ],
  },
  {
    id: "mac",
    name: "Mac",
    icon: "fa-solid fa-laptop",
    status: "later",
    note: "Mac support is planned after the iPhone launch. Apple Silicon only.",
    supported: [
      "MacBook Air (M1)", "MacBook Air (M2)", "MacBook Air (M3)",
      "MacBook Pro (M1)", "MacBook Pro (M2)", "MacBook Pro (M3)", "MacBook Pro (M4)",
      "iMac (M1)", "iMac (M3)", "iMac (M4)",
      "Mac mini (M1)", "Mac mini (M2)", "Mac mini (M4)",
      "Mac Studio (M1)", "Mac Studio (M2)", "Mac Pro (M2 Ultra)",
    ],
    unsupported: ["All Intel Macs"],
  },
];
