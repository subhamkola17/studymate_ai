export default async (request) => {
  // Allow the Flutter web app to call this function
  if (request.method === "OPTIONS") {
    return new Response(null, {
      status: 204,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "Content-Type",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
      },
    });
  }

  if (request.method !== "POST") {
    return new Response(
      JSON.stringify({ error: "Only POST requests are allowed" }),
      {
        status: 405,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    );
  }

  try {
    const body = await request.json();

    const messages = body.messages;

    if (!messages || !Array.isArray(messages)) {
      return new Response(
        JSON.stringify({ error: "Messages are required" }),
        {
          status: 400,
          headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
          },
        }
      );
    }

    // IMPORTANT:
    // The Groq API key is NOT written anywhere in this file.
    // Netlify will provide it through an environment variable.
    const apiKey = process.env.GROQ_API_KEY;

    if (!apiKey) {
      return new Response(
        JSON.stringify({
          error: "GROQ_API_KEY is not configured on Netlify",
        }),
        {
          status: 500,
          headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
          },
        }
      );
    }

    const groqResponse = await fetch(
      "https://api.groq.com/openai/v1/chat/completions",
      {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${apiKey}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          model: "llama-3.3-70b-versatile",
          messages: messages,
        }),
      }
    );

    const data = await groqResponse.json();

    return new Response(JSON.stringify(data), {
      status: groqResponse.status,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
    });
  } catch (error) {
    console.error("Groq function error:", error);

    return new Response(
      JSON.stringify({
        error: "Failed to communicate with Groq",
        details: error.message,
      }),
      {
        status: 500,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    );
  }
};