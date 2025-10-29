from flask import Flask, request, jsonify
import google.generativeai as genai
import os

app = Flask(__name__)

# 配置API密钥 (从环境变量中获取)
genai.configure(api_key=os.getenv("API_KEY"))

# 创建模型实例
model = genai.GenerativeModel(model_name="gemini-2.0-flash")

def make_polite(sentence):
    """将句子转换为更礼貌的表达"""
    prompt = f"""
    You are a polite and professional assistant. Rewrite the following sentence to make it more polite and respectful.
    Just output the rewritten sentence without any explanation.
    Output the corresponding language.

    Sentence: "{sentence}"
    Polite Version:
    """
    try:
        response = model.generate_content(prompt)
        return response.text.strip()
    except Exception as e:
        print(f"Google API error: {e}")
        return f"API调用失败: {e}"
#临时加一个简单测试路由,检查网络请求是否正常响应：curl http://127.0.0.1:5001
@app.route("/", methods=["GET"])
def index():
    return jsonify({"status": "running"})

@app.route("/api/chat", methods=["POST"])
def chat():
    data = request.get_json()
    if not data:
        return jsonify({"error": "Missing JSON payload"}), 400

    user_input = data.get("message")

    if not user_input:
        return jsonify({"error": "Missing user message"}), 400

    polite_reply = make_polite(user_input)

    return jsonify({"reply": polite_reply})

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5001))
    app.run(host="0.0.0.0", port=port, debug=True)

