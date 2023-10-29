public interface HttpMatchingStrategy {
    HttpResponse matchResponse(HttpRequest req, Map<String, HttpResponse> responseStore, Boolean pass, Boolean failOnAuth);
}