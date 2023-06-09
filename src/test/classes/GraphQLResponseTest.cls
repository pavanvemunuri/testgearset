@IsTest(IsParallel = true)
private class GraphQLResponseTest {
    @IsTest
    private static void responseWithErrorOnlyTest() {
        String message = 'Error!';
        GraphQLResponseError error = new GraphQLResponseError(message);
        GraphQLResponse response = new GraphQLResponse(error);
        System.assert(response.hasErrors());
        System.assert(!response.hasData());
        List<GraphQLResponseError> responseErrors = response.getErrors();
        System.assertEquals(1, responseErrors.size());
        System.assertEquals(message, responseErrors.get(0).message);
        System.assert(responseErrors.get(0).locations == null);
        System.assert(responseErrors.get(0).path == null);
        System.assert(responseErrors.get(0).extensions == null);
    }

    @IsTest
    private static void parseFromResponseJsonTest() {
        GraphQLResponse response = prepareErrorResponse();
        System.assert(response.hasErrors());
        System.assert(response.hasData());
        Map<String, Object> responseData = response.getData();
        Map<String, Object> hero = (Map<String, Object>) response.getDataNode('hero');
        List<GraphQLResponseError> responseErrors = response.getErrors();
        System.assertEquals(1, responseErrors.size());
        System.assert(String.isNotBlank(responseErrors.get(0).message));
        System.assertEquals(1, responseErrors.get(0).locations.size());
        System.assertEquals(6, responseErrors.get(0).locations.get(0).line);
        System.assertEquals(7, responseErrors.get(0).locations.get(0).column);
        System.assertEquals(4, responseErrors.get(0).path.size());
        System.assertEquals('hero', responseErrors.get(0).path.get(0));
        System.assertEquals('heroFriends', responseErrors.get(0).path.get(1));
        System.assertEquals(1, (Integer) responseErrors.get(0).path.get(2));
        System.assertEquals('name', responseErrors.get(0).path.get(3));
        System.assertEquals(2, responseErrors.get(0).extensions.size());
        System.assertEquals(200, (Integer) responseErrors.get(0).extensions.get('code'));
        System.assertEquals('Test!', responseErrors.get(0).extensions.get('customField'));
        System.assert(responseData.containsKey('hero'));
        System.assertEquals('R2-D2', (String) hero.get('name'));
    }

    @IsTest
    private static void getErrorExtensionsAsTypeTest() {
        List<GraphQLResponseError> errors = prepareErrorResponse().getErrors();
        GraphQLResponseError firstError = errors.get(0);
        ErrorExtensionsWrapper extensions = (ErrorExtensionsWrapper) firstError
            .getExtensionsAs(ErrorExtensionsWrapper.class);
        System.assert(extensions != null);
        System.assertEquals(200, extensions.code);
        System.assertEquals('Test!', extensions.customField);
    }

    @IsTest
    private static void getDataAsTypeTest() {
        GraphQLResponse response = prepareNoErrorsResponse();
        DataWrapper responseData = (DataWrapper) response.getDataAs(DataWrapper.class);
        System.assert(response.hasData());
        System.assert(!response.hasErrors());
        System.assertEquals(0, response.getErrors().size());
        System.assert(responseData.hero != null);
        System.assertEquals(null, responseData.hero.id);
        System.assertEquals('R2-D2', responseData.hero.name);
        System.assertEquals(2, responseData.hero.heroFriends.size());
    }

    @IsTest
    private static void getDataNodeAsTypeTest() {
        GraphQLResponse response = prepareNoErrorsResponse();
        HeroWrapper hero = (HeroWrapper) response.getDataNodeAs('hero', HeroWrapper.class);
        System.assert(response.hasData());
        System.assert(!response.hasErrors());
        System.assert(hero != null);
        System.assertEquals(null, hero.id);
        System.assertEquals('R2-D2', hero.name);
        System.assertEquals(2, hero.heroFriends.size());
    }

    private static GraphQLResponse prepareNoErrorsResponse() {
        Map<String, Object> response = new Map<String, Object> {
            'data' => new Map<String, Object> {
                'hero' => new Map<String, Object> {
                    'name' => 'R2-D2',
                    'heroFriends' => new List<Object> {
                        new Map<String, Object> { 'id' => '1000', 'name' => 'Luke Skywalker' },
                        new Map<String, Object> { 'id' => '1003', 'name' => 'Leia Organa' }
                    }
                }
            }
        };
        return GraphQLResponse.parse(JSON.serialize(response));
    }

    private static GraphQLResponse prepareErrorResponse() {
        Map<String, Object> response = new Map<String, Object> {
            'errors' => new List<Object> {
                new Map<String, Object> {
                    'message' => 'Name for character with ID 1002 could not be fetched.',
                    'locations' => new List<Object> { new Map<String, Object> { 'line' => 6, 'column' => 7 } },
                    'path' => new List<Object> { 'hero', 'heroFriends', 1, 'name' },
                    'extensions' => new Map<String, Object> { 'code' => 200, 'customField' => 'Test!' }
                }
            },
            'data' => new Map<String, Object> {
                'hero' => new Map<String, Object> {
                    'name' => 'R2-D2',
                    'heroFriends' => new List<Object> {
                        new Map<String, Object> { 'id' => '1000', 'name' => 'Luke Skywalker' },
                        null,
                        new Map<String, Object> { 'id' => '1003', 'name' => 'Leia Organa' }
                    }
                }
            }
        };
        return GraphQLResponse.parse(JSON.serialize(response));
    }

    private class DataWrapper {
        public HeroWrapper hero;
    }

    private class HeroWrapper {
        public String id;
        public String name;
        public List<HeroWrapper> heroFriends;
    }

    private class ErrorExtensionsWrapper {
        public Integer code;
        public String customField;
    }
}
