@IsTest(IsParallel = true)
private class GraphQLSubscriptionTest {
    @IsTest
    private static void emptySubscriptionTest() {
        GraphQLSubscription node = new GraphQLSubscription();

        System.assert(String.isBlank(node.name));
        System.assertEquals(0, node.nodes.size());
    }

    @IsTest
    private static void namedSubscriptionTest() {
        String nodeName = 'Test';

        GraphQLSubscription node = new GraphQLSubscription(nodeName);

        System.assertEquals(nodeName, node.name);
        System.assertEquals(0, node.nodes.size());
    }

    @IsTest
    private static void emptySubscriptionWithChildNodeTest() {
        GraphQLField childNode = new GraphQLField('node1');

        GraphQLSubscription node = new GraphQLSubscription(childNode);

        System.assert(String.isBlank(node.name));
        System.assertEquals(1, node.nodes.size());
    }

    @IsTest
    private static void emptySubscriptionWithChildNodesTest() {
        List<GraphQLField> childNodes = new List<GraphQLField> { new GraphQLField('node1'), new GraphQLField('node2') };

        GraphQLSubscription node = new GraphQLSubscription(childNodes);

        System.assert(String.isBlank(node.name));
        System.assertEquals(childNodes.size(), node.nodes.size());
    }

    @IsTest
    private static void namedSubscriptionWithChildNodeTest() {
        String nodeName = 'Test';

        GraphQLSubscription node = new GraphQLSubscription(nodeName, new GraphQLField('node1'));

        System.assertEquals(nodeName, node.name);
        System.assertEquals(1, node.nodes.size());
    }

    @IsTest
    private static void namedSubscriptionWithChildNodesTest() {
        String nodeName = 'Test';
        List<GraphQLField> childNodes = new List<GraphQLField> { new GraphQLField('node1'), new GraphQLField('node2') };

        GraphQLSubscription node = new GraphQLSubscription(nodeName, childNodes);

        System.assertEquals(nodeName, node.name);
        System.assertEquals(childNodes.size(), node.nodes.size());
    }

    @IsTest
    private static void emptySubscriptionWithFieldsTest() {
        List<String> fields = new List<String> { 'field1', 'field2' };

        GraphQLSubscription node = new GraphQLSubscription(fields);

        System.assert(String.isBlank(node.name));
        System.assertEquals(fields.size(), node.nodes.size());
    }

    @IsTest
    private static void namedSubscriptionWithFieldsTest() {
        String nodeName = 'node';
        List<String> fields = new List<String> { 'field1', 'field2' };

        GraphQLSubscription node = new GraphQLSubscription(nodeName, fields);

        System.assertEquals(nodeName, node.name);
        System.assertEquals(fields.size(), node.nodes.size());
    }

    @IsTest
    private static void subscriptionWithFieldTest() {
        String fieldName = 'field1';

        GraphQLSubscription node = new GraphQLSubscription().withField(fieldName);

        System.assertEquals(1, node.nodes.size());
        System.assertEquals(fieldName, node.nodes.get(0).name);
    }

    @IsTest
    private static void subscriptionWithFieldsTest() {
        List<String> fields = new List<String> { 'field1', 'field2' };

        GraphQLSubscription node = new GraphQLSubscription().withFields(fields);

        System.assertEquals(fields.size(), node.nodes.size());
        System.assertEquals('field1', node.nodes.get(0).name);
        System.assertEquals('field2', node.nodes.get(1).name);
    }

    @IsTest
    private static void subscriptionWithFragmentDefinitionTest() {
        GraphQLFragment fragment = new GraphQLFragment('fragment1', 'Type1');

        GraphQLSubscription node = new GraphQLSubscription().defineFragment(fragment);

        System.assert(node.hasFragments());
        System.assertEquals(1, node.fragments.size());
        System.assertEquals(fragment.name, node.fragments.get(0).name);
    }

    @IsTest
    private static void subscriptionWithFragmentDefinitionsTest() {
        List<GraphQLFragment> fragments = new List<GraphQLFragment> {
            new GraphQLFragment('fragment1', 'Type1'),
            new GraphQLFragment('fragment2', 'Type2')
        };

        GraphQLSubscription node = new GraphQLSubscription().defineFragments(fragments);

        System.assert(node.hasFragments());
        System.assertEquals(fragments.size(), node.fragments.size());
        System.assertEquals('fragment1', node.fragments.get(0).name);
        System.assertEquals('fragment2', node.fragments.get(1).name);
    }

    @IsTest
    private static void subscriptionWithDirectiveTest() {
        GraphQLSubscription subscription = new GraphQLSubscription()
            .withDirective(new GraphQLDirective('test'))
            .withField('field');

        System.assertEquals(1, subscription.directives.size());
        System.assertEquals('subscription@test{field}', subscription.build());
        System.assertEquals('subscription @test {\n  field\n}', subscription.build(true));
    }

    @IsTest
    private static void subscriptionWithFieldNodeTest() {
        String nodeName = 'node1';

        GraphQLSubscription node = new GraphQLSubscription().withField(new GraphQLField(nodeName));

        System.assertEquals(1, node.nodes.size());
        System.assertEquals(nodeName, node.nodes.get(0).name);
    }

    @IsTest
    private static void subscriptionWithFieldNodesTest() {
        List<GraphQLField> nodes = new List<GraphQLField> { new GraphQLField('node1'), new GraphQLField('node2') };

        GraphQLSubscription node = new GraphQLSubscription().withFields(nodes);

        System.assertEquals(nodes.size(), node.nodes.size());
        System.assertEquals('node1', node.nodes.get(0).name);
        System.assertEquals('node2', node.nodes.get(1).name);
    }

    @IsTest
    private static void subscriptionWithVariableDefinitionTest() {
        GraphQLSubscription node = new GraphQLSubscription()
            .withField(new GraphQLField('node'))
            .defineVariable('newVariable', '[Int]! = 0');

        System.assertEquals(1, node.variables.size());
    }

    @IsTest
    private static void subscriptionBuildRequestTest() {
        Exception error;
        try {
            new GraphQLSubscription(new List<String> { 'field1' }).asRequest();
        } catch (Exception ex) {
            error = ex;
        }

        System.assert(error != null);
        System.assert(error instanceof GraphQLOperation.GraphQLOperationException);
    }

    /**
     * E2E tests below
     */

    @IsTest
    private static void buildSubscriptionPositiveTest() {
        List<GraphQLField> nodes = new List<GraphQLField> { new GraphQLField('field1'), new GraphQLField('field2') };
        List<String> fields = new List<String> { 'field3', 'field4' };

        GraphQLSubscription subscription = new GraphQLSubscription()
            .withField(nodes.get(0))
            .withField(nodes.get(1))
            .withFields(fields)
            .withField('field3');

        System.assert(subscription != null);
        System.assert(String.isBlank(subscription.name));
        System.assertEquals(nodes.size() + fields.size(), subscription.nodes.size());
        System.assertEquals('subscription{field1,field2,field3,field4}', subscription.build());
        System.assertEquals('subscription {\n  field1\n  field2\n  field3\n  field4\n}', subscription.build(true));
    }

    @IsTest
    private static void buildSubscriptionWithVariableDefinitionsPositiveTest() {
        List<GraphQLField> nodes = new List<GraphQLField> {
            new GraphQLField('node1').withArgument('arg', '$param1'),
            new GraphQLField('node2')
        };
        List<String> fields = new List<String> { 'field3', 'field4' };

        GraphQLSubscription subscription = new GraphQLSubscription()
            .withFields(nodes)
            .withFields(fields)
            .defineVariable('param1', 'Int!')
            .defineVariable('param2', 'String');

        System.assert(subscription != null);
        System.assert(String.isBlank(subscription.name));
        System.assertEquals(nodes.size() + fields.size(), subscription.nodes.size());
        System.assertEquals(
            'subscription($param1:Int!,$param2:String){node1(arg:$param1),node2,field3,field4}',
            subscription.build()
        );
        System.assertEquals(
            'subscription ($param1: Int!, $param2: String) {\n  node1(arg: $param1)\n  node2\n  field3\n  field4\n}',
            subscription.build(true)
        );
    }

    @IsTest
    private static void buildSubscriptionWithChildNodesPositiveTest() {
        List<GraphQLField> nodes = new List<GraphQLField> {
            new GraphQLField('field1'),
            new GraphQLField(
                'field2',
                new List<GraphQLField> { new GraphQLField('field21'), new GraphQLField('field22') }
            ),
            new GraphQLField('field3')
        };

        GraphQLSubscription subscription = new GraphQLSubscription('TestSubscription', nodes).withField('field1');

        System.assert(Subscription != null);
        System.assertEquals('TestSubscription', subscription.name);
        System.assertEquals(nodes.size(), subscription.nodes.size());
        System.assertEquals(
            'subscription TestSubscription{field1,field2{field21,field22},field3}',
            subscription.build()
        );
        System.assertEquals(
            'subscription TestSubscription {\n  field1\n  field2 {\n    field21\n    field22\n  }\n  field3\n}',
            subscription.build(true)
        );
    }
}
