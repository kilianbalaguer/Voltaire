import re

with open("/Users/kilianbalaguer/Downloads/Voltaire-main/Voltaire/Models/Models.swift", "r") as f:
    content = f.read()

content = content.replace("case .deepseek_r1_distill_qwen_1_5b_4bit, .deepseek_r1_distill_llama_8b_4bit: \"DeepSeek R1\"", "case .deepseek_r1_distill_qwen_1_5b_4bit, .deepseek_r1_distill_qwen_1_5b_8bit, .deepseek_r1_distill_llama_8b_4bit: \"DeepSeek R1\"")

with open("/Users/kilianbalaguer/Downloads/Voltaire-main/Voltaire/Models/Models.swift", "w") as f:
    f.write(content)
