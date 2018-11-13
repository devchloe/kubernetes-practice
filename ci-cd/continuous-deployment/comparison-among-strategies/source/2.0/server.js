'use strict';

const express = require('express');
const app = express();

const PORT = 8080;
const HOST = '0.0.0.0';

app.get('/', (req, res, next) => {
    res.send('Hello version 2.0\n');
});

app.get('/health', (req, res, next) => {
    res.send('/health called..\n');
})

app.get('/ready', (req, res, next) => {
    res.send('/ready called..\n');
})

app.listen(PORT, HOST);
console.log(`Running on http://${HOST}:${PORT}`);

