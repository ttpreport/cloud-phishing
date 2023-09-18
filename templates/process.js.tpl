const AIRTABLE_KEY = '${key}';
const AIRTABLE_ID = '${id}';
const AIRTABLE_TABLE = '${table}';

export default async (request, response) => {
    response.setHeader('Access-Control-Allow-Origin', '*')
    response.setHeader('Access-Control-Allow-Methods', 'OPTIONS, POST')
    
    if (request.method === 'OPTIONS') {
        return response.status(200).end();
    }

    const { email } = request.body;

    try {
        const cf_response = await fetch('https://api.airtable.com/v0/'+AIRTABLE_ID+'/'+AIRTABLE_TABLE, {
            body: JSON.stringify({
                "records": [
                  {
                    "fields": {
                      "email": email
                    }
                  }
                ]
              }),
            method: 'POST',
            headers: {
                "Authorization": "Bearer " + AIRTABLE_KEY,
                "Content-Type": "application/json",
            },
        });

        await cf_response.json();
        return response.send("OK");
    } catch(err) {
        return response.send("ERROR");
    }
}