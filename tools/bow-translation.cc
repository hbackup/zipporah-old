#include <iostream>
#include <fstream>
#include <unordered_map>
#include <vector>
#include <string>
#include <sstream>
#include <map>

using namespace std;

struct TransProb {
  TransProb(string w, double p):
    word(w), prob(p) {}
  string word;
  double prob;
};

vector<string> Split(string input) {
  vector<string> ans;
  string word;
  stringstream ss(input);
  while (ss >> word) {
    ans.push_back(word);
  }
  return ans;
}

double ToDouble(string input) {
  stringstream ss(input);
  double ans = 0;
  ss >> ans;
  return ans;
}

unordered_map<string, double> GetUnigram(istream &input) {
  unordered_map<string, double> ans;
  string word;
  int count;
  int total_count = 0;
  while (input >> count >> word) {
    ans[word] = count;
    total_count += count;
  }

  for (unordered_map<string, double>::iterator iter = ans.begin();
                                               iter != ans.end();
                                               iter++) {
    iter->second /= double(total_count);
  }

  // sanity check
  double total_prob = 0.0;
  for (unordered_map<string, double>::iterator iter = ans.begin();
                                               iter != ans.end();
                                               iter++) {
    total_prob += iter->second;
  }
  assert(total_prob > 0.99 && total_prob < 1.01);

  return ans;
}

unordered_map<string, vector<TransProb> > GetTable(istream &input) {
  unordered_map<string, vector<TransProb> > ans;

  string line;
  while (getline(input, line)) {
    vector<string> words = Split(line);
    string key = words[1];
    string value = words[0];
    double prob = ToDouble(words[2]);

    if (ans.find(key) != ans.end()) {
      ans[key].push_back(TransProb(value, prob));
    } else {
      ans[key] = vector<TransProb>();
      ans[key].push_back(TransProb(value, prob));
    }
  }

/*
  for (unordered_map<string, vector<TransProb> >::iterator iter = ans.begin();
                                                           iter != ans.end();
                                                           iter++) {
    double sum = 0.0;
    for (size_t i = 0; i < iter->second.size(); i++) {
      cout << iter->first << ": " << iter->second[i].word << ", " << iter->second[i].prob << endl;
      sum += iter->second[i].prob;
    }
    cout << "sum is " << sum << endl;
  }
// */
  return ans;
}

void DoTranslate(const unordered_map<string, vector<TransProb> >&table,
                 const unordered_map<string, double> &unigram,
                 istream& input) {
  string line;
  int lines_processed = 0;
  while (getline(input, line)) {
    map<string, double> ans;
    vector<string> words = Split(line);

    for (size_t i = 0; i < words.size(); i++) {
      const unordered_map<string, vector<TransProb> >::const_iterator
        iter = table.find(words[i]);
      if (iter == table.end()) {
        // OOV, words not apperaing in the lex
//        ans["OOOOOOOOV"] = ans["OOOOOOOOV"] + 1.0;
        continue;
      }
      double uni_prob = unigram[words[i]];

      const vector<TransProb>& t = iter->second;

      for (size_t j = 0; j < t.size(); j++) {
        ans[t[j].word] += t[j].prob * uni_prob;
//        cout << "adding proba " << t[j].prob << endl;
      }
    }

    for (map<string, double>::iterator iter = ans.begin();
                                       iter != ans.end();
                                       iter++) {
      cout << iter->first << " " << iter->second << " ";
    }
    cout << endl;
    /*
    if (lines_processed++ % 1000 == 999) {
      cerr << "processing line: " << lines_processed << endl;
    }
    //*/
  }
}

int main(int argc, char** argv) {
  if (argc != 4) {
    cerr << argv[0] << "table-file unigram-counts file-to-translate" << endl
         << endl
         << argv[0] << " requires 3 parameters; got instead " << argc << endl;
    return -1;
  }

  string table_file = argv[1];
  string unigram_count_file = argv[2];
  string file_to_translate = argv[3];

  if (table_file == "-" && file_to_translate == "-") {
    cerr << "Can not have stdin for both inputs" << endl;
    return -1;
  }

  unordered_map<string, vector<TransProb> > table;

  cerr << "# Starting Reading Table" << endl;

  if (table_file == "-") {
    table = GetTable(cin);
  } else {
    ifstream ifile(table_file);
    table = GetTable(ifile);
  }

  {
    ifstream ifile(unigram_count_file);
    unigram = GetUnigram(ifile);
  }

  cerr << "# Starting Translation" << endl;

  if (file_to_translate == "-") {
    DoTranslate(table, unigram, cin);
  } else {
    ifstream ifile(file_to_translate);
    DoTranslate(table, unigram, ifile);
  }
  return 0;
}
