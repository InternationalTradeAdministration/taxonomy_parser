require 'spec_helper'

describe Extractors::ClassExtractor do
  let(:extractor) do
    # xml = ConsolidatedXmlDocument.parse Pathname.new('spec/fixtures/extractors/imported_ontology.owl'),
    #                                     Pathname.new('spec/fixtures/extractors/concepts_root_ontology.owl')
    xml = OwlZipReader.read './spec/fixtures/webprotege.zip'
    described_class.new xml
  end

  describe '#extract' do
    it 'returns Industries concept' do
      actual_concepts = extractor.extract.values

      expected_hash = {
        id: 'R8CoATsjiZSLAZF4Aaz6kK6',
        label: 'Aerospace and Defense',
        type: ['Industries'],
        annotations: {
          alt_label: ['Aerospace Industry', 'Defense Industry'],
          pref_label: ['Aerospace and Defense'],
          source: ['ITA']
        },
        object_properties: {
          has_narrower: [
            { id: 'RDBsKPGzqliWT5godmR5PDV', label: 'Aviation' },
            { id: 'R9lHhOo010EPhoajnKC2Lvg', label: 'Defense Equipment' },
            { id: 'R3anJjpDBXy092dEyJ0nXU', label: nil }
          ],
          is_main_concept_in_collection: [
            { id: 'R79uIjoQaQ9KzvJfyB1H7Ru', label: 'Industries' }
          ] }
      }

      actual_concept_hash = actual_concepts.detect { |cg| cg[:label] == 'Aerospace and Defense' }
      # binding.pry
      expect(actual_concept_hash).to eq(expected_hash)
    end

    it 'returns Industries sub class concept' do
      expected_hash = {
        id: 'RDBsKPGzqliWT5godmR5PDV',
        label: 'Aviation',
        annotations: {
          alt_label: ['Passenger Flights', 'Air Transportation', 'Aviation Services', 'Aviation Industry'],
          definition: ['The industry involved in the operation of commercial, non-military passenger and cargo transportation by air. The category features aviation transport businesses and organizations, as well as those providing supplies and services to this industry.'],
          pref_label: ['Aviation'],
          source: ['ITA']
        },
        type: ['Industries'],
        object_properties: {
          has_broader: [
            { id: 'R8CoATsjiZSLAZF4Aaz6kK6', label: 'Aerospace and Defense' }
          ],
          has_narrower: [
            { id: 'R9sYmPzKkdKVRi2X3oObIyM', label: nil },
            { id: 'R635cvqm6BBP8Jzu7yW6oh', label: nil },
            { id: 'RvXfDHB5h5CSXPVpkb2gUJ', label: nil },
            { id: 'R83KkvcNAEbR5GIN8ALouQW', label: nil },
            { id: 'RBs1GcA7YB0XYJPwBZgk5xR', label: nil },
            { id: 'RB5EzH3O2Hn4aqHGmKIXaJb', label: nil },
            { id: 'R8AFRGW0gBQe3oP4WiY3o9s', label: nil }
          ],
          is_in_scheme: [
            { id: 'RC7BwiZbq5uJvqujC7p9NAy', label: 'Thesaurus of International Trade and Investment Terms' }
          ]
        }
      }

      actual_concepts = extractor.extract.values
      actual_concept_hash = actual_concepts.detect { |cg| cg[:label] == 'Aviation' }
      expect(actual_concept_hash).to eq(expected_hash)
    end

    it 'returns Countries concept' do
      expected_hash = {
        id: 'R8sDBgF7EMZhgZUjx5EUhwi',
        label: 'Peru',
        annotations: {
          pref_label: ['Peru'],
          source: ['ISO 3166']
        },
        type: ['Countries'],
        object_properties: {
          has_broader: [
            { id: 'R4Tyoniw0wZl3t7In4gVGW', label: 'Pacific Rim' },
            { id: 'RBNzCOB6MPHkIcAr36FNe4Q', label: nil },
            { id: 'RD1qG8h2SlYrcW9LSFriQ2d', label: nil },
            { id: 'RC7yMOkNtsKp6PxYXaWc3He', label: nil }
          ],
          has_related: [
            { id: 'R8QeCXxFOyplkfg4SI30D6w', label: nil },
            { id: 'RB53lPnm186ivFLEXmbWylT', label: nil },
            { id: 'R7YQAlNP4iXuBJLBhgPAcIO', label: nil },
            { id: 'R9H8fTryqnqoG9WBuzDGlGt', label: nil },
            { id: 'RMWO1fpkJ5LvTSEZyAAl3K', label: nil }
          ],
          is_main_concept_in_collection: [
            { id: 'RCzwUJdLiYabKMRXxVGNvf8', label: 'U.S. Free Trade Agreement Partner Countries' },
            { id: 'R8W91u35GBegWcXXFflYE4', label: 'Countries' }
          ]
        }
      }

      actual_concepts = extractor.extract.values
      actual_aviation_concept_hash = actual_concepts.detect { |cg| cg[:label] == 'Peru' }
      expect(actual_aviation_concept_hash).to eq(expected_hash)
    end

    it 'returns trade region concepts' do
      expected_hash = {
        id: 'RBYST5TkMsG3aOT9QMbCYFF',
        label: 'African Growth and Opportunity Act',
        type: ['Trade Regions'],
        annotations: {
          alt_label: ['AGOA'],
          definition: ['The African Growth and Opportunity Act (AGOA) legislation that establishes a a nonreciprocal trade preference program providing duty-free treatment to U.S. imports of certain products from eligible Sub- Saharan African countries.'],
          pref_label: ['African Growth and Opportunity Act']
        },
        object_properties: {
          has_broader: [
            { id: 'Rt8hC8B97usWz6X1JOhP32', label: 'Trade Preference Programs' }],
          has_related: [
            { id: 'R8DdIMDFzHvwLDKQu30RRmN', label: 'Sub-Saharan Africa' },
            { id: "RDkR6Coi999FtjJzavA1ytE", label: nil }
          ],
          is_in_scheme: [
            { id: 'RC7BwiZbq5uJvqujC7p9NAy', label: 'Thesaurus of International Trade and Investment Terms' }
          ],
          is_main_concept_in_collection: [
            { id: 'R7ySyiNxcfeZ6bfNjhocNun', label: 'Trade Regions' }
          ]
        }
      }

      # binding.pry
      actual_concepts = extractor.extract.values
      actual_aviation_concept_hash = actual_concepts.detect { |cg| cg[:label] == 'African Growth and Opportunity Act' }
      expect(actual_aviation_concept_hash).to eq(expected_hash)
    end

    it 'returns U.S. States and Territories concept' do
      expected_hash = {
        id: 'R8EQ1rTm3YaOBhcjtH1NGt6',
        label: 'District of Columbia',
        type: ['U.S. States and Territories'],
        annotations: {
          alt_label: ['Washington, DC'],
          pref_label: ['District of Columbia'],
          source: ['ISO 3166']
        },
        object_properties: {
          has_broader: [
            { id: 'RC4HD9CwKjvgX8dSybAp3Sk', label: 'United States' }
          ],
          is_main_concept_in_collection: [
            { id: 'Rqdpj5QSp8PxZGtrXuOpdK', label: 'U.S. States and Territories' }
          ]
        }
      }

      actual_concepts = extractor.extract.values
      actual_concept_hash = actual_concepts.detect { |c| c[:label] == 'District of Columbia' }
      expect(actual_concept_hash).to eq(expected_hash)
    end

    it 'returns World Regions concept' do
      expected_hash = {
        id: 'RYpfofeF7tAALNfD2cMbaP',
        label: 'Africa',
        type: ['World Regions'],
        annotations: {
          pref_label: ['Africa'],
          source: ['ITA']
        },
        object_properties: {
          has_narrower: [
            { id: 'RPAxEt4cHXZPPJ587s5tlG', label: nil },
            { id: 'R8DdIMDFzHvwLDKQu30RRmN', label: 'Sub-Saharan Africa' },
            { id: 'R7q9jrGbpXPRPccAu33iNNU', label: nil }
          ],
          has_related: [
            { id: 'RDkqAkKpM7hCxY84UQAuLaj', label: nil }
          ],
          is_main_concept_in_collection: [
            { id: 'R8cndKa2D8NuNg7djwJcXxB', label: 'World Regions' }
          ]
        }
      }

      actual_concepts = extractor.extract.values
      actual_concept_hash = actual_concepts.detect { |cg| cg[:label] == 'Africa' }
      expect(actual_concept_hash).to eq(expected_hash)
    end

    it 'returns World Regions sub concept' do
      expected_hash = {
        id: 'R8DdIMDFzHvwLDKQu30RRmN',
        label: 'Sub-Saharan Africa',
        type: ['World Regions'],
        annotations: {
          alt_label: ['SubSaharan Africa', 'Sub Saharan Africa'],
          pref_label: ['Sub-Saharan Africa'],
          source: ['ITA']
        },
        object_properties: {
          has_broader: [
            { id: 'RYpfofeF7tAALNfD2cMbaP', label: 'Africa' }
          ],
          has_narrower: [
            { id: 'R84vd2fSNWZmsinYehOK6aG', label: nil },
            { id: 'RBAVlisida7HGDpQBhwirCd', label: nil },
            { id: 'RDFbgSy3LZrH6PRhU3Ah9FK', label: 'South Africa' }
          ],
          has_related: [
            { id: 'RDzPvl6rgNC4szHLAsCM13', label: nil },
            { id: 'R2hRDhgUBIzDSqa22tDdHt', label: 'South African Customs Union' },
            { id: 'RDUgllCOnvIkkxDg7dNcusj', label: nil }
          ],
          member_of: [
            { id: 'R8cndKa2D8NuNg7djwJcXxB', label: 'World Regions' }
          ]
        }
      }

      actual_concepts = extractor.extract.values
      actual_concept_hash = actual_concepts.detect { |cg| cg[:label] == 'Sub-Saharan Africa' }
      expect(actual_concept_hash).to eq(expected_hash)
    end

    it 'returns Trade Topics concept' do
      expected_hash = {
        id: 'Rt8hC8B97usWz6X1JOhP32',
        label: 'Trade Preference Programs',
        annotations: {
          alt_label: ['Trade Preferences'],
          definition: ['A Trade Preference Program is legislated by the U.S. Congress and provides duty-free treatment to certain products from designated beneficiary countries that meet the programs rules.'],
          pref_label: ['Trade Preference Programs'],
          source: ['ITA']
        },
        type: ['Trade Topics'],
        object_properties: {
          has_narrower: [
            { id: 'RBYST5TkMsG3aOT9QMbCYFF', label: 'African Growth and Opportunity Act' },
            { id: 'R8G6sSHw1tiYAx1glqZQrdN', label: nil }
          ],
          is_main_concept_in_collection: [
            { id: 'RDlBzieEBJR6LAcbiT7mdYC', label: 'Trade Policy and Agreements' }
          ]
        }
      }

      actual_concepts = extractor.extract.values
      actual_concept_hash = actual_concepts.detect { |cg| cg[:label] == 'Trade Preference Programs' }
      expect(actual_concept_hash).to eq(expected_hash)
    end

    it 'returns Trade Topics sub concept' do
      expected_hash = {
        id: 'RH26UG6XlwMz5U93jvnGxo',
        label: 'Value Added Taxes',
        annotations: {
          pref_label: ['Value Added Taxes'],
          source: ['ITA']
        },
        type: ['Trade Topics'],
        object_properties: {
          has_broader: [
            { id: "RCT5JJbnQHlplbh7WIiAdLV", label: "Tariffs" }
          ]
        }
      }

      actual_concepts = extractor.extract.values
      actual_concept_hash = actual_concepts.detect { |cg| cg[:label] == 'Value Added Taxes' }
      expect(actual_concept_hash).to eq(expected_hash)
    end

    it 'returns Trade Topics concept under sub group' do
      expected_hash = {
        id: 'RCi51S9bucjjV1FGpkDyMhq',
        label: 'Safeguards',
        annotations: {
          pref_label: ['Safeguards'],
          source: ['UNCTAD/WTO']
        },
        type: ['Trade Topics'],
        object_properties: {
          has_related: [
            { id: "RDkR6Coi999FtjJzavA1ytE", label: nil },
            { id: "RCRHog7jT4RwmJZVs4fvOq2", label: nil },
            { id: "Rxe6uQeredRAyMxXbswm89", label: "Trade Barriers" }
          ],
          is_main_concept_in_collection: [
            { id: "RNy7fDXpMAmlGj4e5mLIeO", label: "Foreign Trade Remedies" }
          ],
          member_of: [
            { id: "RNy7fDXpMAmlGj4e5mLIeO", label: "Foreign Trade Remedies" }
          ]
        }
      }

      actual_concepts = extractor.extract.values
      actual_concept_hash = actual_concepts.detect { |cg| cg[:label] == 'Safeguards' }
      expect(actual_concept_hash).to eq(expected_hash)
    end
  end
end
