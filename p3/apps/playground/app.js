// Basic setup from official Express documentation:
// https://expressjs.com/

const express = require('express')
const app = express()
const port = 8888

app.get('/', (req, res) => {
  res.send({
    "status": "ok",
    "message": "v1"
  })
})

app.listen(port, '0.0.0.0', () => {
  console.log(`Example app listening on port ${port}`)
})
