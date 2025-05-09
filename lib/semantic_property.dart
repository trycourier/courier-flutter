class SemanticProperty {
  final String name;
  final String value;

  SemanticProperty(this.name, this.value);

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
    };
  }

  factory SemanticProperty.fromJson(Map<String, dynamic> json) {
    return SemanticProperty(
      json['name'],
      json['value'],
    );
  }
}

class SemanticProperties {
  final List<SemanticProperty> properties;

  SemanticProperties(this.properties);

  Map<String, dynamic> toJson() {
    return {
      'properties': properties.map((e) => e.toJson()).toList(),
    };
  }

  factory SemanticProperties.fromJson(Map<String, dynamic> json) {
    return SemanticProperties(
      (json['properties'] as List).map<SemanticProperty>((e) => SemanticProperty.fromJson(e)).toList(),
    );
  }
}