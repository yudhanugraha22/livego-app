const CryptoJS = require("crypto-js");
const axios = require("axios");

const secret = "22dfb2b849814054af0491ff2ee3ffe33989313d7d38e97aae659757a4cf8960";
const path = "/api/v2/home?category_p=melolo&lang=id";
const ts = Date.now().toString();
const sig = CryptoJS.HmacSHA256("GET:" + path + ":" + ts, secret).toString();

axios.get("https://api-drama.dobda.id" + path, {
    headers: { "X-Timestamp": ts, "X-Signature": sig }
})
.then(res => console.log("HASIL: SUKSES! Data ditemukan: " + res.data.data.length + " film"))
.catch(err => console.log("HASIL: GAGAL! Pesan: " + (err.response ? err.response.data.message : err.message)));
