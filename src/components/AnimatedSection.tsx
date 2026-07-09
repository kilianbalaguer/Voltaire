"use client";

import { motion } from "framer-motion";
import React from "react";

type AnimationVariant = {
  hidden: Record<string, number | string>;
  visible: Record<string, number | string>;
};

export default function AnimatedSection({
  children,
  variants,
  className,
  delay = 0,
}: {
  children: React.ReactNode;
  variants?: AnimationVariant;
  className?: string;
  delay?: number;
}) {
  return (
    <motion.div
      initial="hidden"
      whileInView="visible"
      viewport={{ once: true, margin: "-80px" }}
      variants={variants}
      transition={{ duration: 0.6, delay, ease: "easeOut" }}
      className={className}
    >
      {children}
    </motion.div>
  );
}
