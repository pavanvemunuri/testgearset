@IsTest(IsParallel = true)
private class GraphQLRequestTest {
    @IsTest
    private static void requestAsStringNodeQueryPositiveTest() {
        String stringNode = 'query{field1, field2}';

        GraphQLRequest request = new GraphQLRequest(stringNode);

        System.assertEquals(GraphQLRequest.DEFAULT_REQUEST_TIMEOUT, request.timeout);
        System.assertEquals(GraphQLOperationType.Query, request.operation);
        System.assertEquals('{"query":"query{field1, field2}"}', request.toString());
        System.assertEquals('{\n  "query" : "query{field1, field2}"\n}', request.toString(true));
    }

    @IsTest
    private static void requestAsStringNodeMutationPositiveTest() {
        String stringNode = 'mutation{field1, field2}';

        GraphQLRequest request = new GraphQLRequest(stringNode);

        System.assertEquals(GraphQLOperationType.Mutation, request.operation);
        System.assertEquals('{"query":"mutation{field1, field2}"}', request.toString());
        System.assertEquals('{\n  "query" : "mutation{field1, field2}"\n}', request.toString(true));
    }

    @IsTest
    private static void requestAsEmptyStringNodeNegativeTest() {
        Exception error;
        try {
            GraphQLRequest request = new GraphQLRequest((String) null);
        } catch (Exception ex) {
            error = ex;
        }

        System.assert(error != null);
        System.assertEquals('The provided string node is empty or in invalid format', error.getMessage());
    }

    @IsTest
    private static void requestAsStringNodeSubscriptionNegativeTest() {
        String stringNode = 'subscription{onNotificationCreated{message}}';
        Exception error;
        try {
            GraphQLRequest request = new GraphQLRequest(stringNode);
        } catch (Exception ex) {
            error = ex;
        }

        System.assert(error != null);
        System.assertEquals('This operation is not allowed for GraphQL request', error.getMessage());
    }

    @IsTest
    private static void requestWithoutOperationTest() {
        GraphQLQuery node = new GraphQLQuery(new List<String> { 'field1', 'field2' });

        GraphQLRequest request = new GraphQLRequest(node);

        System.assertEquals(GraphQLOperationType.Query, request.operation);
        System.assertEquals('{"query":"query{field1,field2}"}', request.toString());
        System.assertEquals('{\n  "query" : "query {\\n  field1\\n  field2\\n}"\n}', request.toString(true));
    }

    @IsTest
    private static void requestWithIncorrectRootNodeTypeNegativeTest() {
        Exception error;
        try {
            new GraphQLRequest(new GraphQLSubscription());
        } catch (Exception err) {
            error = err;
        }

        System.assert(error != null);
        System.assertEquals('The request node should be an either a Query or Mutation node', error.getMessage());
    }

    @IsTest
    private static void requestWithOperationTest() {
        GraphQLMutation node = new GraphQLMutation(new List<String> { 'field1', 'field2' });

        GraphQLRequest request = new GraphQLRequest(node);

        System.assertEquals(GraphQLOperationType.Mutation, request.operation);
        System.assertEquals('{"query":"mutation{field1,field2}"}', request.toString());
        System.assertEquals('{\n  "query" : "mutation {\\n  field1\\n  field2\\n}"\n}', request.toString(true));
    }

    @IsTest
    private static void requestWithHeaderTest() {
        GraphQLOperationType operation = GraphQLOperationType.Mutation;
        GraphQLMutation node = new GraphQLMutation(new List<String> { 'field1', 'field2' });

        GraphQLRequest request = new GraphQLRequest(node).withHeader('Authorization', 'token');

        System.assertEquals(1, request.headers.size());
        System.assertEquals('token', request.headers.get('Authorization'));
    }

    @IsTest
    private static void requestWithTimeoutTest() {
        GraphQLOperationType operation = GraphQLOperationType.Mutation;
        GraphQLMutation node = new GraphQLMutation(new List<String> { 'field1', 'field2' });

        GraphQLRequest request = new GraphQLRequest(node).withTimeout(10000);

        System.assertEquals(10000, request.timeout);
    }

    @IsTest
    private static void requestWithVariableTest() {
        GraphQLOperationType operation = GraphQLOperationType.Mutation;
        GraphQLMutation node = new GraphQLMutation(new List<String> { 'field1', 'field2' });

        GraphQLRequest request = new GraphQLRequest(node).withVariable('param', 'value');

        System.assertEquals('{"variables":{"param":"value"},"query":"mutation{field1,field2}"}', request.toString());
    }
}
