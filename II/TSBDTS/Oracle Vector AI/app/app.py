import os
import oracledb
from flask import Flask, jsonify, render_template_string, request
from sentence_transformers import SentenceTransformer
from constants import *
from utils import *

app = Flask(__name__)

def init_app():
    loaded_model = SentenceTransformer(MODEL_NAME)
    init_utils(loaded_model)

HTML_TEMPLATE = """
<!DOCTYPE html>

<html lang="ro"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>Recomandare de filme | Cyber-Premium</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&amp;display=swap" rel="stylesheet"/>
<style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', sans-serif;
            background: #10131a;
            background-image: 
                radial-gradient(circle at 20% 30%, rgba(139, 92, 246, 0.05) 0%, transparent 40%),
                radial-gradient(circle at 80% 70%, rgba(34, 211, 238, 0.05) 0%, transparent 40%);
            color: #e2e8f0;
            min-height: 100vh;
            line-height: 1.6;
        }

        .container {
            max-width: 1100px;
            margin: 0 auto;
            padding: 40px 24px;
        }

        header {
            text-align: center;
            padding: 48px 0 40px;
        }

        header h1 {
            font-size: 2.8em;
            font-weight: 800;
            letter-spacing: -0.02em;
            background: linear-gradient(135deg, #ffffff 0%, #a78bfa 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 12px;
        }

        header p {
            color: #94a3b8;
            font-size: 1.1em;
            max-width: 700px;
            margin: 0 auto;
        }

        .search-section {
            background: rgba(30, 41, 59, 0.4);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            border-radius: 16px;
            padding: 32px;
            margin: 24px 0;
            border: 1px solid rgba(139, 92, 246, 0.15);
            box-shadow: 0 4px 24px rgba(0, 0, 0, 0.2);
            transition: transform 0.3s ease, border-color 0.3s ease;
        }

        .search-section:hover {
            border-color: rgba(139, 92, 246, 0.4);
            box-shadow: 0 4px 30px rgba(139, 92, 246, 0.1);
        }

        .search-section h2 {
            color: #f8fafc;
            margin-bottom: 8px;
            font-size: 1.4em;
            font-weight: 700;
        }

        .section-text {
            color: #94a3b8;
            margin-bottom: 20px;
            font-size: 0.95em;
        }

        .search-row {
            display: flex;
            gap: 12px;
        }

        .search-row input,
        .search-row select {
            flex: 1;
            padding: 14px 18px;
            border-radius: 12px;
            border: 1px solid rgba(255, 255, 255, 0.1);
            background: rgba(15, 23, 42, 0.6);
            color: #f8fafc;
            font-size: 1em;
            outline: none;
            transition: all 0.2s ease;
        }

        .search-row input:focus,
        .search-row select:focus {
            border-color: #8B5CF6;
            box-shadow: 0 0 0 4px rgba(139, 92, 246, 0.15);
        }

        .search-row input::placeholder {
            color: #64748b;
        }

        .btn {
            padding: 14px 28px;
            border: none;
            border-radius: 12px;
            cursor: pointer;
            font-size: 1em;
            font-weight: 700;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            white-space: nowrap;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .btn-primary {
            background: #8B5CF6;
            color: #ffffff;
            box-shadow: 0 4px 14px rgba(139, 92, 246, 0.3);
        }

        .btn-primary:hover {
            background: #7c3aed;
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(139, 92, 246, 0.4);
        }

        .btn-secondary {
            background: rgba(34, 211, 238, 0.1);
            color: #22d3ee;
            border: 1px solid rgba(34, 211, 238, 0.2);
        }

        .btn-secondary:hover {
            background: rgba(34, 211, 238, 0.2);
            border-color: #22d3ee;
            transform: translateY(-2px);
        }

        .section-title {
            color: #f8fafc;
            margin: 48px 0 24px;
            font-size: 1.75em;
            font-weight: 800;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .section-title::after {
            content: "";
            flex: 1;
            height: 1px;
            background: linear-gradient(to right, rgba(139, 92, 246, 0.3), transparent);
        }

        .movie-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 20px;
            margin: 20px 0;
        }

        .movie-card {
            background: rgba(30, 41, 59, 0.3);
            backdrop-filter: blur(8px);
            border-radius: 16px;
            padding: 24px;
            border: 1px solid rgba(255, 255, 255, 0.05);
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            cursor: pointer;
            position: relative;
            overflow: hidden;
        }

        .movie-card::before {
            content: "";
            position: absolute;
            top: 0;
            left: 0;
            width: 4px;
            height: 0;
            background: #8B5CF6;
            transition: height 0.3s ease;
        }

        .movie-card:hover {
            background: rgba(30, 41, 59, 0.5);
            border-color: rgba(139, 92, 246, 0.3);
            transform: translateY(-5px);
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
        }

        .movie-card:hover::before {
            height: 100%;
        }

        .movie-card h3 {
            font-size: 1.2em;
            margin-bottom: 12px;
            color: #f8fafc;
            font-weight: 700;
        }

        .movie-meta {
            display: flex;
            gap: 6px;
            flex-wrap: wrap;
            margin-bottom: 16px;
        }

        .tag {
            background: rgba(139, 92, 246, 0.1);
            color: #a78bfa;
            padding: 4px 10px;
            border-radius: 6px;
            font-size: 0.7em;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            border: 1px solid rgba(139, 92, 246, 0.2);
        }

        .tag-rating {
            background: rgba(34, 211, 238, 0.1);
            color: #22d3ee;
            border: 1px solid rgba(34, 211, 238, 0.2);
        }

        .movie-desc {
            font-size: 0.9em;
            color: #94a3b8;
            line-height: 1.6;
            display: -webkit-box;
            -webkit-line-clamp: 3;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }

        .recommendations {
            margin: 40px 0;
            padding: 32px;
            background: rgba(15, 23, 42, 0.5);
            backdrop-filter: blur(16px);
            border-radius: 20px;
            border: 1px solid rgba(139, 92, 246, 0.2);
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.4), 0 0 20px rgba(139, 92, 246, 0.05);
        }

        .recommendations h2 {
            color: #f8fafc;
            margin-bottom: 8px;
            font-weight: 800;
        }

        .recommendations .subtitle {
            color: #64748b;
            margin-bottom: 24px;
            font-size: 0.95em;
        }

        .rec-card {
            display: flex;
            align-items: center;
            gap: 20px;
            background: rgba(30, 41, 59, 0.4);
            border-radius: 14px;
            padding: 20px;
            margin-bottom: 16px;
            border: 1px solid rgba(255, 255, 255, 0.05);
            transition: border-color 0.2s ease;
        }

        .rec-card:hover {
            border-color: rgba(34, 211, 238, 0.3);
        }

        .rec-rank {
            min-width: 40px;
            height: 40px;
            background: rgba(139, 92, 246, 0.15);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #a78bfa;
            font-weight: 800;
            font-size: 1.1em;
            border: 1px solid rgba(139, 92, 246, 0.3);
        }

        .rec-info {
            flex: 1;
        }

        .rec-info h3 {
            color: #f8fafc;
            margin-bottom: 4px;
            font-size: 1.1em;
            font-weight: 700;
        }

        .rec-info .rec-meta {
            color: #64748b;
            font-size: 0.85em;
            margin-bottom: 8px;
            font-weight: 500;
        }

        .rec-desc {
            color: #94a3b8;
            font-size: 0.88em;
            line-height: 1.5;
        }

        .rec-score {
            min-width: 80px;
            text-align: right;
            color: #22d3ee;
            font-size: 1.1em;
            font-weight: 800;
            text-shadow: 0 0 10px rgba(34, 211, 238, 0.4);
        }

        .loading {
            text-align: center;
            padding: 40px;
            display: none;
        }

        .spinner {
            width: 48px;
            height: 48px;
            border: 3px solid rgba(139, 92, 246, 0.1);
            border-top-color: #8B5CF6;
            border-radius: 50%;
            animation: spin 1s cubic-bezier(0.5, 0.1, 0.5, 0.9) infinite;
            margin: 0 auto 16px;
            box-shadow: 0 0 15px rgba(139, 92, 246, 0.2);
        }

        @keyframes spin {
            to { transform: rotate(360deg); }
        }

        .footer {
            text-align: center;
            padding: 60px 20px;
            color: #64748b;
            font-size: 0.85em;
            border-top: 1px solid rgba(255, 255, 255, 0.05);
            margin-top: 40px;
        }

        .footer p {
            margin-top: 8px;
        }

        /* Custom Scrollbar */
        ::-webkit-scrollbar {
            width: 8px;
        }
        ::-webkit-scrollbar-track {
            background: #10131a;
        }
        ::-webkit-scrollbar-thumb {
            background: rgba(139, 92, 246, 0.2);
            border-radius: 10px;
        }
        ::-webkit-scrollbar-thumb:hover {
            background: rgba(139, 92, 246, 0.4);
        }

        @media (max-width: 768px) {
            header h1 { font-size: 2em; }
            .search-row { flex-direction: column; }
            .rec-card { flex-direction: column; align-items: flex-start; gap: 12px; }
            .rec-score { text-align: left; min-width: auto; }
            .rec-rank { width: 32px; height: 32px; min-width: 32px; font-size: 0.9em; }
        }
    </style>
</head>
<body>
<div class="container">
<header>
<h1>Recomandare de filme</h1>
<p>Descoperă universul cinematografic folosind algoritmi avansați de recomandare bazate pe descrieri și contexte.</p>
</header>
<div class="search-section">
<h2>Căutare după descriere</h2>
<p class="section-text">
                Explorează filme prin limbaj natural. Descrie atmosfera sau subiectul căutat.
            </p>
<div class="search-row">
<input id="searchInput" onkeypress="if(event.key==='Enter') searchByText()" placeholder="Ex: un film despre familie, speranță și sacrificiu" type="text"/>
<button class="btn btn-primary" onclick="searchByText()">
                    Caută filme
                </button>
</div>
</div>
<div class="search-section">
<h2>Recomandări pe baza unui film selectat</h2>
<p class="section-text">
                Găsește titluri cu o dinamică și structură similară cu favoritul tău.
            </p>
<div class="search-row">
<select id="movieSelect">
<option value="">-- Alege un film --</option>
                    {% for movie in movies %}
                    <option value="{{ movie.id }}">{{ movie.title }} ({{ movie.year }})</option>
                    {% endfor %}
                </select>
<button class="btn btn-secondary" onclick="getRecommendations()">Vezi recomandări</button>
</div>
</div>
<div class="loading" id="loading">
<div class="spinner"></div>
<p style="color: #a78bfa; font-weight: 500;">Se procesează cererea folosind IA...</p>
</div>
<div id="results"></div>
<h2 class="section-title">Baza de date cinematografică</h2>
<div class="movie-grid">
            {% for movie in movies %}
            <div class="movie-card" onclick="selectMovie({{ movie.id }})">
<h3>{{ movie.title }}</h3>
<div class="movie-meta">
<span class="tag">{{ movie.genre }}</span>
<span class="tag">{{ movie.year }}</span>
<span class="tag tag-rating">★ {{ movie.rating }}</span>
</div>
<p class="movie-desc">{{ movie.description }}</p>
</div>
            {% endfor %}
        </div>
<div class="footer">
<p>Proiect misto - dev here, are potential :)</p>
</div>
</div>
<script>
        function selectMovie(id) {
            document.getElementById('movieSelect').value = id;
            getRecommendations();
        }

        async function getRecommendations() {
            const movieId = document.getElementById('movieSelect').value;

            if (!movieId) {
                alert('Selectează un film.');
                return;
            }

            showLoading();

            try {
                const res = await fetch(`/api/recommend/${movieId}`);
                const data = await res.json();

                displayResults(
                    `Recomandări pentru "${data.source_movie.title}"`,
                    'Filme corelate semantic cu selecția ta.',
                    data.recommendations
                );
            } catch (err) {
                document.getElementById('results').innerHTML =
                    '<p style="color:#ef4444; text-align:center; padding: 20px;">A apărut o eroare la obținerea recomandărilor.</p>';
            }

            hideLoading();
        }

        async function searchByText() {
            const query = document.getElementById('searchInput').value.trim();

            if (!query) {
                alert('Scrie o descriere.');
                return;
            }

            showLoading();

            try {
                const res = await fetch('/api/search', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ query: query })
                });

                const data = await res.json();

                displayResults(
                    `Rezultate pentru: "${query}"`,
                    'Cele mai relevante potriviri găsite în baza de date.',
                    data.results
                );
            } catch (err) {
                document.getElementById('results').innerHTML =
                    '<p style="color:#ef4444; text-align:center; padding: 20px;">A apărut o eroare la căutare.</p>';
            }

            hideLoading();
        }

        function displayResults(title, subtitle, items) {
            let html = `
                <div class="recommendations">
                    <h2>${title}</h2>
                    <p class="subtitle">${subtitle}</p>
            `;

            items.forEach((item, i) => {
                const similarity = ((1 - item.distance) * 100).toFixed(1);

                html += `
                    <div class="rec-card">
                        <div class="rec-rank">${i + 1}</div>
                        <div class="rec-info">
                            <h3>${item.title}</h3>
                            <div class="rec-meta">
                                <span style="color:#a78bfa">${item.genre}</span> • ${item.year} • 
                                <span style="color:#22d3ee">★ ${item.rating}</span>
                            </div>
                            <p class="rec-desc">${item.description.substring(0, 150)}...</p>
                        </div>
                        <div class="rec-score">${similarity}% <span style="font-size: 0.6em; display:block; font-weight:400; opacity:0.7">match</span></div>
                    </div>
                `;
            });

            html += '</div>';
            document.getElementById('results').innerHTML = html;
            document.getElementById('results').scrollIntoView({ behavior: 'smooth' });
        }

        function showLoading() {
            document.getElementById('loading').style.display = 'block';
            document.getElementById('results').innerHTML = '';
        }

        function hideLoading() {
            document.getElementById('loading').style.display = 'none';
        }
    </script>
</body></html>
"""


@app.route("/")
def index():
    movies = get_all_movies()
    return render_template_string(HTML_TEMPLATE, movies=movies)


@app.route("/api/recommend/<int:movie_id>")
def api_recommend(movie_id):
    source = get_movie_by_id(movie_id)

    if not source:
        return jsonify({"error": "Film negăsit"}), 404

    recommendations = get_recommendations_by_movie(movie_id, top_n=5)
    return jsonify({
        "source_movie": source,
        "recommendations": recommendations
    })


@app.route("/api/search", methods=["POST"])
def api_search():
    data = request.get_json()
    query = data.get("query", "").strip()

    if not query:
        return jsonify({"error": "Query gol"}), 400

    results = search_by_text(query, top_n=5)
    return jsonify({
        "query": query,
        "results": results
    })


@app.route("/api/movies")
def api_movies():
    return jsonify(get_all_movies())


if __name__ == "__main__":
    init_app()
    host = FLASK_HOST
    port = FLASK_PORT
    debug = FLASK_DEBUG

    app.run(host=host, port=port, debug=debug, use_reloader=False)