import json, boto3, os, uuid
from datetime import datetime 

dynamodb = boto3.resource('dynamodb')
sns = boto3.client('sns')

def lambda_handler(event, context):
    method = event.get('requestContext', {}).get('http', {}).get('method') or event.get('httpMethod') or 'GET'
    
    SNS_ARN = os.environ.get('SNS_TOPIC_ARN', '')
    VISITOR_TABLE = os.environ.get('VISITOR_TABLE', 'VisitorCount')
    COMMENT_TABLE = os.environ.get('COMMENT_TABLE', 'ResumeComments')

    print(f"DEBUG: Method: {method}")
    print(f"DEBUG: Event: {json.dumps(event)}")

    if method == 'OPTIONS':
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'GET,POST,OPTIONS',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Max-Age': '86400',
                'Content-Type': 'application/json'
            },
            'body': json.dumps({})
        }

    try:
        if method == 'GET':
            table = dynamodb.Table(VISITOR_TABLE)
            res = table.update_item(
                Key={'id': '0'},
                UpdateExpression='ADD visitor_count :inc',
                ExpressionAttributeValues={':inc': 1},
                ReturnValues='UPDATED_NEW'
            )
            return {
                'statusCode': 200,
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type',
                    'Access-Control-Allow-Methods': 'GET,POST,OPTIONS',
                    'Content-Type': 'application/json'
                },
                'body': json.dumps({"count": str(res['Attributes']['visitor_count'])})
            }

        elif method == 'POST':
            # Xử lý body từ API Gateway
            body_str = event.get('body', '{}')
            print(f"DEBUG: Raw body: {body_str}")
            
            # Giải mã body nếu cần
            if event.get('isBase64Encoded', False):
                import base64
                body_str = base64.b64decode(body_str).decode('utf-8')
            
            try:
                body = json.loads(body_str)
            except:
                body = {}
            
            name = body.get('name', 'Guest')
            msg = body.get('message', '')
            
            print(f"DEBUG: Name: {name}, Message: {msg}")

            if not msg:
                return {
                    'statusCode': 400,
                    'headers': {'Access-Control-Allow-Origin': '*', 'Content-Type': 'application/json'},
                    'body': json.dumps({"error": "Message is required"})
                }

            table = dynamodb.Table(COMMENT_TABLE)
            table.put_item(Item={
                'comment_id': str(uuid.uuid4()),
                'name': name,
                'message': msg,
                'timestamp': datetime.now().isoformat()
            })
            
            if SNS_ARN:
                sns.publish(
                    TopicArn=SNS_ARN,
                    Subject=f"CV Comment from {name}",
                    Message=f"Name: {name}\nMessage: {msg}"
                )
                
            return {
                'statusCode': 200,
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Content-Type': 'application/json'
                },
                'body': json.dumps({"message": "Sent Success!"})
            }

        else:
            return {
                'statusCode': 404,
                'headers': {'Access-Control-Allow-Origin': '*'},
                'body': json.dumps({"error": "Method not supported"})
            }

    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {'Access-Control-Allow-Origin': '*'},
            'body': json.dumps({"error": str(e)})
        }