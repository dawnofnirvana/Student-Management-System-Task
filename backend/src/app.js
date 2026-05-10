const express = require("express");
const cookieParser = require("cookie-parser");
const dotenv = require("dotenv");
const cors = require("cors");
const path = require("path");

dotenv.config();

const { handle404Error, handleGlobalError } = require("./middlewares");
const { v1Routes } = require("./routes/v1");

const app = express();

const corsOrigins = process.env.CORS_ORIGIN
  ? process.env.CORS_ORIGIN.split(",").map((origin) => origin.trim())
  : ["http://localhost:5173"];

const corsOptions = {
  origin: function (origin, callback) {
    if (!origin || corsOrigins.includes(origin)) {
      return callback(null, true);
    }

    return callback(new Error(`Not allowed by CORS: ${origin}`));
  },
  credentials: true,
};

app.use(cors(corsOptions));

app.use(express.json());
app.use(express.static(path.join(__dirname, "..", "public")));
app.use(cookieParser());

app.use("/api/v1", v1Routes);

app.use(handle404Error);
app.use(handleGlobalError);

module.exports = { app };