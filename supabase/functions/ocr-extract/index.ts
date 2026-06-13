import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { imageUrl } = await req.json();

    if (!imageUrl) {
      return jsonResponse(
        {
          success: false,
          error: "imageUrl is required",
        },
        400,
      );
    }

    const geminiApiKey = Deno.env.get("GEMINI_API_KEY");
    if (!geminiApiKey) {
      return jsonResponse(
        {
          success: false,
          error: "GEMINI_API_KEY is not configured",
        },
        500,
      );
    }

    const imageResponse = await fetch(imageUrl);
    if (!imageResponse.ok) {
      return jsonResponse(
        {
          success: false,
          error: `Unable to fetch image from storage: ${imageResponse.status}`,
        },
        400,
      );
    }

    const imageBuffer = await imageResponse.arrayBuffer();
    const base64Image = arrayBufferToBase64(imageBuffer);
    const mimeType =
      imageResponse.headers.get("content-type")?.split(";")[0] ?? "image/jpeg";

    const geminiResponse = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${geminiApiKey}`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          contents: [
            {
              parts: [
                {
                  text: `
You are an ingredient extraction engine.

Read the food label image and extract the ingredients section.

Return ONLY valid JSON in this exact format:
{
  "raw_text": "full OCR text if available",
  "ingredients_text": "comma separated ingredients section only",
  "ingredients": ["Ingredient 1", "Ingredient 2"],
  "confidence": 0.0
}
                  `,
                },
                {
                  inlineData: {
                    mimeType,
                    data: base64Image,
                  },
                },
              ],
            },
          ],
          generationConfig: {
            temperature: 0,
            responseMimeType: "application/json",
          },
        }),
      },
    );

    const geminiData = await geminiResponse.json();

    if (!geminiResponse.ok) {
      return jsonResponse(
        {
          success: false,
          error: "Gemini OCR request failed",
          details: geminiData,
        },
        500,
      );
    }

    const text = geminiData?.candidates?.[0]?.content?.parts?.[0]?.text;
    if (!text) {
      return jsonResponse(
        {
          success: false,
          error: "Gemini did not return OCR text",
          details: geminiData,
        },
        500,
      );
    }

    let parsed;
    try {
      parsed = JSON.parse(text);
    } catch (_) {
      parsed = {
        raw_text: text,
        ingredients_text: text,
        ingredients: [],
        confidence: 0,
      };
    }

    return jsonResponse(parsed, 200);
  } catch (error) {
    return jsonResponse(
      {
        success: false,
        error: error instanceof Error ? error.message : String(error),
      },
      500,
    );
  }
});

function jsonResponse(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
    },
  });
}

function arrayBufferToBase64(buffer: ArrayBuffer): string {
  const bytes = new Uint8Array(buffer);
  const chunkSize = 0x8000;
  let binary = "";

  for (let index = 0; index < bytes.length; index += chunkSize) {
    const chunk = bytes.subarray(index, index + chunkSize);
    binary += String.fromCharCode(...chunk);
  }

  return btoa(binary);
}
