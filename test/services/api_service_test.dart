import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:campsite_finder/services/api_service.dart';
import 'package:campsite_finder/models/campsite.dart';

// Generate mocks
@GenerateMocks([Dio])
import '../services/api_service_test.mocks.dart';

void main() {
  group('ApiService Tests', () {
    late ApiService apiService;
    late MockDio mockDio;

    setUp(() {
      mockDio = MockDio();
      when(mockDio.options).thenReturn(BaseOptions(baseUrl: 'https://62ed0389a785760e67622eb2.mockapi.io/spots/v1'));
      apiService = ApiService(dio: mockDio);
    });

    const mockCampsiteData = [
      {
        'id': '1',
        'label': 'Beautiful Lake Campsite',
        'photo': 'https://example.com/photo1.jpg',
        'geoLocation': {
          'lat': 52520.0,
          'long': 13405.0,
        },
        'isCloseToWater': true,
        'isCampFireAllowed': false,
        'hostLanguages': ['English', 'German'],
        'pricePerNight': 2500.0,
        'suitableFor': ['families', 'couples'],
        'createdAt': '2023-01-01T00:00:00.000Z',
      },
      {
        'id': '2',
        'label': 'Mountain View Spot',
        'photo': 'https://example.com/photo2.jpg',
        'geoLocation': {
          'lat': 47370.0,
          'long': 8540.0,
        },
        'isCloseToWater': false,
        'isCampFireAllowed': true,
        'hostLanguages': ['German', 'French'],
        'pricePerNight': 3000.0,
        'suitableFor': ['couples', 'solo'],
        'createdAt': '2023-01-02T00:00:00.000Z',
      },
    ];

    group('getCampsites', () {
      test('should return list of campsites on successful response', () async {
        // Arrange
        final response = Response<List<dynamic>>(
          data: mockCampsiteData,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/campsites'),
        );

        when(mockDio.get('/campsites')).thenAnswer((_) async => response);

        // Act
        final result = await apiService.getCampsites();

        // Assert
        expect(result, isA<List<Campsite>>());
        expect(result.length, equals(2));
        expect(result[0].id, equals('1'));
        expect(result[0].label, equals('Beautiful Lake Campsite'));
        expect(result[1].id, equals('2'));
        expect(result[1].label, equals('Mountain View Spot'));

        verify(mockDio.get('/campsites')).called(1);
      });

      test('should throw ApiException on non-200 status code', () async {
        // Arrange
        final response = Response<List<dynamic>>(
          data: null,
          statusCode: 404,
          requestOptions: RequestOptions(path: '/campsites'),
        );

        when(mockDio.get('/campsites')).thenAnswer((_) async => response);

        // Act & Assert
        expect(
              () async => await apiService.getCampsites(),
          throwsA(isA<ApiException>().having(
                (e) => e.statusCode,
            'statusCode',
            equals(404),
          )),
        );
      });

      test('should throw ApiException on connection timeout', () async {
        // Arrange
        when(mockDio.get('/campsites')).thenThrow(
          DioException(
            type: DioExceptionType.connectionTimeout,
            requestOptions: RequestOptions(path: '/campsites'),
          ),
        );

        // Act & Assert
        expect(
              () async => await apiService.getCampsites(),
          throwsA(isA<ApiException>().having(
                (e) => e.message,
            'message',
            contains('Connection timeout'),
          )),
        );
      });

      test('should throw ApiException on send timeout', () async {
        // Arrange
        when(mockDio.get('/campsites')).thenThrow(
          DioException(
            type: DioExceptionType.sendTimeout,
            requestOptions: RequestOptions(path: '/campsites'),
          ),
        );

        // Act & Assert
        expect(
              () async => await apiService.getCampsites(),
          throwsA(isA<ApiException>().having(
                (e) => e.message,
            'message',
            contains('Connection timeout'),
          )),
        );
      });

      test('should throw ApiException on receive timeout', () async {
        // Arrange
        when(mockDio.get('/campsites')).thenThrow(
          DioException(
            type: DioExceptionType.receiveTimeout,
            requestOptions: RequestOptions(path: '/campsites'),
          ),
        );

        // Act & Assert
        expect(
              () async => await apiService.getCampsites(),
          throwsA(isA<ApiException>().having(
                (e) => e.message,
            'message',
            contains('Connection timeout'),
          )),
        );
      });

      test('should throw ApiException on connection error', () async {
        // Arrange
        when(mockDio.get('/campsites')).thenThrow(
          DioException(
            type: DioExceptionType.connectionError,
            requestOptions: RequestOptions(path: '/campsites'),
          ),
        );

        // Act & Assert
        expect(
              () async => await apiService.getCampsites(),
          throwsA(isA<ApiException>().having(
                (e) => e.message,
            'message',
            contains('No internet connection'),
          )),
        );
      });

      test('should throw ApiException on bad response', () async {
        // Arrange
        when(mockDio.get('/campsites')).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            response: Response(
              statusCode: 500,
              statusMessage: 'Internal Server Error',
              requestOptions: RequestOptions(path: '/campsites'),
            ),
            requestOptions: RequestOptions(path: '/campsites'),
          ),
        );

        // Act & Assert
        expect(
              () async => await apiService.getCampsites(),
          throwsA(isA<ApiException>().having(
                (e) => e.message,
            'message',
            contains('Server error: Internal Server Error'),
          )),
        );
      });

      test('should throw ApiException on request cancellation', () async {
        // Arrange
        when(mockDio.get('/campsites')).thenThrow(
          DioException(
            type: DioExceptionType.cancel,
            requestOptions: RequestOptions(path: '/campsites'),
          ),
        );

        // Act & Assert
        expect(
              () async => await apiService.getCampsites(),
          throwsA(isA<ApiException>().having(
                (e) => e.message,
            'message',
            contains('Request was cancelled'),
          )),
        );
      });

      test('should throw ApiException on unknown error', () async {
        // Arrange
        when(mockDio.get('/campsites')).thenThrow(
          DioException(
            type: DioExceptionType.unknown,
            requestOptions: RequestOptions(path: '/campsites'),
          ),
        );

        // Act & Assert
        expect(
              () async => await apiService.getCampsites(),
          throwsA(isA<ApiException>().having(
                (e) => e.message,
            'message',
            contains('Network error occurred'),
          )),
        );
      });

      test('should throw ApiException on unexpected error', () async {
        // Arrange
        when(mockDio.get('/campsites')).thenThrow(
          Exception('Unexpected error'),
        );

        // Act & Assert
        expect(
              () async => await apiService.getCampsites(),
          throwsA(isA<ApiException>().having(
                (e) => e.message,
            'message',
            contains('Unexpected error occured'),
          )),
        );
      });

      test('should handle empty response data', () async {
        // Arrange
        final response = Response<List<dynamic>>(
          data: [],
          statusCode: 200,
          requestOptions: RequestOptions(path: '/campsites'),
        );

        when(mockDio.get('/campsites')).thenAnswer((_) async => response);

        // Act
        final result = await apiService.getCampsites();

        // Assert
        expect(result, isA<List<Campsite>>());
        expect(result.length, equals(0));
      });

      test('should handle malformed JSON data', () async {
        // Arrange
        const malformedData = [
          {
            'id': '1',
            'label': 'Test Campsite',
            // Missing required fields
          }
        ];

        final response = Response<List<dynamic>>(
          data: malformedData,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/campsites'),
        );

        when(mockDio.get('/campsites')).thenAnswer((_) async => response);

        // Act & Assert
        expect(
              () async => await apiService.getCampsites(),
          throwsA(isA<ApiException>()),
        );
      });
    });
  });

  group('ApiException Tests', () {
    test('should create ApiException with message and status code', () {
      const exception = ApiException('Test error', 404);

      expect(exception.message, equals('Test error'));
      expect(exception.statusCode, equals(404));
    });

    test('should have correct toString representation', () {
      const exception = ApiException('Test error', 404);

      expect(exception.toString(), equals('ApiException: Test error (Status: 404)'));
    });
  });
}