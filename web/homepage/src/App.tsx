import './App.css';
import logo from './logo.svg';

function App() {
  return (
    <header className="introHeader">
      <img src={logo} alt="Grape" className="logo"/>
      <div className="introHeaderContent">
        <h1>Grape is an array accelerator,<br/>designed from scratch.</h1>
        <p>
          Grape blends the programmability of an FPGA with the
          performance of systolic arrays through a CGRA architecture.
          Each Grape accelerator contains a grid of functional units
          which can be programmed and connected to one another to implement
          most dataflow graphs. Grape is programmed using Juno, a medium-level
          programming language which supports scheduling code across accelerators
          and CPUs. Grape is under active development with an anticipated fabrication
          date of December 2024, and this website will be regularly updated
          with new content.
          </p>
        <p><a className="introLearnMore" href="https://github.com/dkw-fan-club/chip">View GitHub</a></p>
      </div>
    </header>
  );
}

export default App;
