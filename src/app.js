exports.handler = async (event) => {
    console.log("Event:", JSON.stringify(event));

    // Support CORS
    const headers = {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "Content-Type",
        "Access-Control-Allow-Methods": "OPTIONS,POST,GET"
    };

    if (event.httpMethod === "OPTIONS") {
        return { statusCode: 200, headers, body: "" };
    }

    try {
        const body = JSON.parse(event.body || "{}");
        const userMessage = (body.message || "").toLowerCase();

        let reply = "Hello! I'm Cloudy ☁️, your friendly AWS Free Tier Advisor! Ask me about EC2, S3, Lambda, or DynamoDB free tiers!";

        if (userMessage.includes("ec2")) {
            reply = "For EC2, the AWS Free Tier includes 750 hours per month of t2.micro or t3.micro instances for your first 12 months! 💻";
        } else if (userMessage.includes("s3")) {
            reply = "For S3, you get 5 GB of standard storage, 20,000 Get Requests, and 2,000 Put Requests per month for your first 12 months! 🪣";
        } else if (userMessage.includes("lambda")) {
            reply = "Lambda is amazing! It has an Always Free tier: 1 million free requests per month and 400,000 GB-seconds of compute time per month! ⚡️";
        } else if (userMessage.includes("dynamodb")) {
            reply = "DynamoDB offers an Always Free tier! You get 25 GB of storage, and 25 provisioned Write and Read Capacity Units (WCU/RCU). 🗄️";
        } else if (userMessage.includes("hi") || userMessage.includes("hello")) {
            reply = "Hello there! I'm Cloudy ☁️! I can help you figure out what's free on AWS. Try asking me about Lambda or S3!";
        } else if (userMessage.length > 0) {
            reply = "I'm still learning! Right now I know the most about EC2, S3, Lambda, and DynamoDB. Want to hear about one of those? 🤔";
        }

        return {
            statusCode: 200,
            headers,
            body: JSON.stringify({
                reply: reply
            })
        };
    } catch (error) {
        console.error(error);
        return {
            statusCode: 500,
            headers,
            body: JSON.stringify({ reply: "Oops! My fluffy clouds got tangled. Please try again! 🌧️" })
        };
    }
};
